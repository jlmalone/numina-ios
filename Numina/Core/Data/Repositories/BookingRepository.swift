//
//  BookingRepository.swift
//  Numina
//
//  Repository for booking data operations
//

import Foundation
import SwiftData

final class BookingRepository {
    private let apiClient: APIClient
    private let modelContext: ModelContext?

    init(apiClient: APIClient = .shared, modelContext: ModelContext? = nil) {
        self.apiClient = apiClient
        self.modelContext = modelContext
    }

    // MARK: - Fetch Bookings

    func getBookings(upcoming: Bool? = nil, fromCache: Bool = false) async throws -> [Booking] {
        if fromCache {
            return try getCachedBookings(upcoming: upcoming)
        }

        let response: BookingListResponse = try await apiClient.request(
            endpoint: .getBookings(upcoming: upcoming)
        )

        let bookings = response.bookings.map { $0.toModel() }

        // Cache bookings
        try await cacheBookings(bookings)

        return bookings
    }

    // MARK: - Create Booking

    func createBooking(classId: String, reminderEnabled: Bool = true, reminderTime: Int? = 60) async throws -> Booking {
        let request = CreateBookingRequest(
            classId: classId,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime
        )

        let bookingDTO: BookingDTO = try await apiClient.request(
            endpoint: .createBooking,
            body: request
        )

        let booking = bookingDTO.toModel()

        // Add to cache
        try await cacheBooking(booking)

        return booking
    }

    // MARK: - Update Booking

    func updateBooking(id: String, reminderEnabled: Bool?, reminderTime: Int?) async throws -> Booking {
        let request = UpdateBookingRequest(
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime
        )

        let bookingDTO: BookingDTO = try await apiClient.request(
            endpoint: .updateBooking(id: id),
            body: request
        )

        let booking = bookingDTO.toModel()

        // Update cache
        try await cacheBooking(booking)

        return booking
    }

    // MARK: - Mark Attended

    func markAttended(id: String) async throws -> (booking: Booking, streakUpdated: Bool, newStreak: Int?) {
        let response: MarkAttendedResponse = try await apiClient.request(
            endpoint: .markAttended(id: id)
        )

        let booking = response.booking.toModel()

        // Update cache
        try await cacheBooking(booking)

        return (booking, response.streakUpdated, response.newStreak)
    }

    // MARK: - Cancel Booking

    func cancelBooking(id: String) async throws -> Booking {
        let bookingDTO: BookingDTO = try await apiClient.request(
            endpoint: .cancelBooking(id: id)
        )

        let booking = bookingDTO.toModel()

        // Update cache
        try await cacheBooking(booking)

        return booking
    }

    // MARK: - Calendar

    func getCalendarMonth(month: String, fromCache: Bool = false) async throws -> [Booking] {
        if fromCache {
            return try getCachedBookingsForMonth(month: month)
        }

        let response: CalendarMonthResponse = try await apiClient.request(
            endpoint: .getCalendarMonth(month: month)
        )

        let bookings = response.bookings.map { $0.toModel() }

        // Cache bookings
        try await cacheBookings(bookings)

        return bookings
    }

    func getCalendarExport() async throws -> CalendarExportResponse {
        return try await apiClient.request(
            endpoint: .getCalendarExport
        )
    }

    // MARK: - Reminder Preferences

    func getReminderPreferences(fromCache: Bool = false) async throws -> ReminderPreferences {
        if fromCache, let cached = try getCachedReminderPreferences() {
            return cached
        }

        let preferencesDTO: ReminderPreferencesDTO = try await apiClient.request(
            endpoint: .getReminderPreferences
        )

        // Get current user ID (should come from auth)
        let userId = "current" // TODO: Get from AuthManager

        let preferences = preferencesDTO.toModel(userId: userId)

        // Cache preferences
        try await cacheReminderPreferences(preferences)

        return preferences
    }

    func updateReminderPreferences(_ preferences: ReminderPreferences) async throws -> ReminderPreferences {
        let preferencesDTO: ReminderPreferencesDTO = try await apiClient.request(
            endpoint: .updateReminderPreferences,
            body: preferences.toDTO()
        )

        let userId = preferences.userId
        let updated = preferencesDTO.toModel(userId: userId)

        // Update cache
        try await cacheReminderPreferences(updated)

        return updated
    }

    // MARK: - Stats

    func getAttendanceStats(fromCache: Bool = false) async throws -> AttendanceStats {
        if fromCache, let cached = try getCachedStats() {
            return cached
        }

        let statsDTO: AttendanceStatsDTO = try await apiClient.request(
            endpoint: .getAttendanceStats
        )

        // Get current user ID
        let userId = "current" // TODO: Get from AuthManager

        let stats = statsDTO.toModel(userId: userId)

        // Cache stats
        try await cacheStats(stats)

        return stats
    }

    func getStreak() async throws -> StreakDTO {
        return try await apiClient.request(
            endpoint: .getStreak
        )
    }

    // MARK: - Local Cache

    @MainActor
    private func cacheBookings(_ bookings: [Booking]) throws {
        guard let context = modelContext else { return }

        // Insert or update bookings
        for booking in bookings {
            // Check if booking exists
            let descriptor = FetchDescriptor<Booking>(
                predicate: #Predicate { $0.id == booking.id }
            )

            let existing = try context.fetch(descriptor)

            // Remove existing
            for existingBooking in existing {
                context.delete(existingBooking)
            }

            // Insert new
            context.insert(booking)
        }

        try context.save()
    }

    @MainActor
    private func cacheBooking(_ booking: Booking) throws {
        guard let context = modelContext else { return }

        // Check if booking exists
        let descriptor = FetchDescriptor<Booking>(
            predicate: #Predicate { $0.id == booking.id }
        )

        let existing = try context.fetch(descriptor)

        // Remove existing
        for existingBooking in existing {
            context.delete(existingBooking)
        }

        // Insert new
        context.insert(booking)
        try context.save()
    }

    private func getCachedBookings(upcoming: Bool? = nil) throws -> [Booking] {
        guard let context = modelContext else { return [] }

        var predicate: Predicate<Booking>?

        if let upcoming = upcoming {
            let now = Date()
            if upcoming {
                predicate = #Predicate { $0.startTime > now }
            } else {
                predicate = #Predicate { $0.endTime < now }
            }
        }

        let descriptor = FetchDescriptor<Booking>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startTime)]
        )

        return try context.fetch(descriptor)
    }

    private func getCachedBookingsForMonth(month: String) throws -> [Booking] {
        guard let context = modelContext else { return [] }

        // Parse month string (yyyy-MM)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        guard let monthDate = formatter.date(from: month) else {
            return []
        }

        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return []
        }

        let descriptor = FetchDescriptor<Booking>(
            predicate: #Predicate { booking in
                booking.startTime >= monthStart && booking.startTime <= monthEnd
            },
            sortBy: [SortDescriptor(\.startTime)]
        )

        return try context.fetch(descriptor)
    }

    @MainActor
    private func cacheReminderPreferences(_ preferences: ReminderPreferences) throws {
        guard let context = modelContext else { return }

        // Remove existing
        let descriptor = FetchDescriptor<ReminderPreferences>()
        let existing = try context.fetch(descriptor)

        for pref in existing {
            context.delete(pref)
        }

        // Insert new
        context.insert(preferences)
        try context.save()
    }

    private func getCachedReminderPreferences() throws -> ReminderPreferences? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<ReminderPreferences>()
        return try context.fetch(descriptor).first
    }

    @MainActor
    private func cacheStats(_ stats: AttendanceStats) throws {
        guard let context = modelContext else { return }

        // Remove existing
        let descriptor = FetchDescriptor<AttendanceStats>()
        let existing = try context.fetch(descriptor)

        for stat in existing {
            context.delete(stat)
        }

        // Insert new
        context.insert(stats)
        try context.save()
    }

    private func getCachedStats() throws -> AttendanceStats? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<AttendanceStats>()
        return try context.fetch(descriptor).first
    }
}
