//
//  BookingsViewModel.swift
//  Numina
//
//  ViewModel for bookings management
//

import Foundation
import SwiftData

@MainActor
final class BookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showUpcomingOnly = true
    @Published var selectedBooking: Booking?

    private let bookingRepository: BookingRepository
    private let eventKitService = EventKitService.shared

    init(bookingRepository: BookingRepository) {
        self.bookingRepository = bookingRepository
    }

    // MARK: - Load Bookings

    func loadBookings(fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            bookings = try await bookingRepository.getBookings(
                upcoming: showUpcomingOnly ? true : nil,
                fromCache: fromCache
            )
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshBookings() async {
        await loadBookings(fromCache: false)
    }

    // MARK: - Create Booking

    func createBooking(classId: String, reminderEnabled: Bool = true, reminderTime: Int? = 60) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let booking = try await bookingRepository.createBooking(
                classId: classId,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime
            )

            // Add to local list
            bookings.insert(booking, at: 0)

            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        return false
    }

    // MARK: - Update Booking

    func updateBookingReminder(id: String, enabled: Bool, time: Int?) async -> Bool {
        errorMessage = nil

        do {
            let updatedBooking = try await bookingRepository.updateBooking(
                id: id,
                reminderEnabled: enabled,
                reminderTime: time
            )

            // Update in local list
            if let index = bookings.firstIndex(where: { $0.id == id }) {
                bookings[index] = updatedBooking
            }

            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        return false
    }

    // MARK: - Mark Attended

    func markAsAttended(id: String) async -> (success: Bool, streakUpdated: Bool, newStreak: Int?) {
        errorMessage = nil

        do {
            let result = try await bookingRepository.markAttended(id: id)

            // Update in local list
            if let index = bookings.firstIndex(where: { $0.id == id }) {
                bookings[index] = result.booking
            }

            return (true, result.streakUpdated, result.newStreak)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        return (false, false, nil)
    }

    // MARK: - Cancel Booking

    func cancelBooking(id: String) async -> Bool {
        errorMessage = nil

        do {
            let cancelledBooking = try await bookingRepository.cancelBooking(id: id)

            // Update in local list
            if let index = bookings.firstIndex(where: { $0.id == id }) {
                bookings[index] = cancelledBooking
            }

            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        return false
    }

    // MARK: - Calendar Export

    func exportToCalendar(booking: Booking) async -> Bool {
        do {
            // Request calendar access
            let granted = try await eventKitService.requestCalendarAccess()

            guard granted else {
                errorMessage = "Calendar access denied. Please grant permission in Settings."
                return false
            }

            // Add to calendar
            _ = try eventKitService.addBookingToCalendar(booking)

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func exportAllToCalendar() async -> Bool {
        do {
            // Request calendar access
            let granted = try await eventKitService.requestCalendarAccess()

            guard granted else {
                errorMessage = "Calendar access denied. Please grant permission in Settings."
                return false
            }

            // Filter upcoming bookings
            let upcomingBookings = bookings.filter { $0.isUpcoming && $0.status == "confirmed" }

            _ = try eventKitService.addMultipleBookingsToCalendar(upcomingBookings)

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Computed Properties

    var upcomingBookings: [Booking] {
        bookings.filter { $0.isUpcoming && $0.status != "cancelled" }
            .sorted { $0.startTime < $1.startTime }
    }

    var pastBookings: [Booking] {
        bookings.filter { $0.isPast }
            .sorted { $0.startTime > $1.startTime }
    }

    var todayBookings: [Booking] {
        bookings.filter { $0.isToday && $0.status != "cancelled" }
            .sorted { $0.startTime < $1.startTime }
    }

    var confirmedCount: Int {
        bookings.filter { $0.status == "confirmed" }.count
    }

    var attendedCount: Int {
        bookings.filter { $0.attended }.count
    }
}
