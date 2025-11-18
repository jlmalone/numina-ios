//
//  CalendarViewModel.swift
//  Numina
//
//  ViewModel for calendar views
//

import Foundation
import SwiftData

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var calendarViewMode: CalendarViewMode = .month

    private let bookingRepository: BookingRepository

    enum CalendarViewMode {
        case month
        case week
        case day
    }

    init(bookingRepository: BookingRepository) {
        self.bookingRepository = bookingRepository
    }

    // MARK: - Load Calendar Data

    func loadMonthData(month: Date, fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthString = formatter.string(from: month)

        do {
            bookings = try await bookingRepository.getCalendarMonth(month: monthString, fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshCurrentMonth() async {
        await loadMonthData(month: currentMonth, fromCache: false)
    }

    // MARK: - Calendar Navigation

    func navigateToNextMonth() {
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = nextMonth
            Task {
                await loadMonthData(month: currentMonth)
            }
        }
    }

    func navigateToPreviousMonth() {
        if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = previousMonth
            Task {
                await loadMonthData(month: currentMonth)
            }
        }
    }

    func navigateToToday() {
        currentMonth = Date()
        selectedDate = Date()
        Task {
            await loadMonthData(month: currentMonth)
        }
    }

    // MARK: - Computed Properties

    var bookingsForSelectedDate: [Booking] {
        let calendar = Calendar.current
        return bookings.filter { booking in
            calendar.isDate(booking.startTime, inSameDayAs: selectedDate)
        }.sorted { $0.startTime < $1.startTime }
    }

    var bookingsForSelectedWeek: [Booking] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }

        return bookings.filter { booking in
            booking.startTime >= weekInterval.start && booking.startTime < weekInterval.end
        }.sorted { $0.startTime < $1.startTime }
    }

    var daysInCurrentMonth: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }

        var dates: [Date] = []
        var date = monthInterval.start

        while date < monthInterval.end {
            dates.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else {
                break
            }
            date = nextDate
        }

        return dates
    }

    var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    var currentWeekDates: [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }

        var dates: [Date] = []
        var date = weekInterval.start

        for _ in 0..<7 {
            dates.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else {
                break
            }
            date = nextDate
        }

        return dates
    }

    func bookingsForDate(_ date: Date) -> [Booking] {
        let calendar = Calendar.current
        return bookings.filter { booking in
            calendar.isDate(booking.startTime, inSameDayAs: date)
        }
    }

    func hasBookings(on date: Date) -> Bool {
        !bookingsForDate(date).isEmpty
    }

    func bookingCount(on date: Date) -> Int {
        bookingsForDate(date).count
    }
}
