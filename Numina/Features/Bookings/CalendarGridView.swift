//
//  CalendarGridView.swift
//  Numina
//
//  Monthly calendar grid
//

import SwiftUI

struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: {
                    viewModel.navigateToPreviousMonth()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.orange)
                }

                Spacer()

                Text(viewModel.currentMonthName)
                    .font(.title3.weight(.bold))

                Spacer()

                Button(action: {
                    viewModel.navigateToNextMonth()
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)

            // Week Days Header
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            // Calendar Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(calendarDates, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            bookingCount: viewModel.bookingCount(on: date),
                            isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                            isToday: Calendar.current.isDateInToday(date)
                        )
                        .onTapGesture {
                            viewModel.selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal)

            // Selected Date Bookings
            if !viewModel.bookingsForSelectedDate.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bookings on \(formattedSelectedDate)")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(viewModel.bookingsForSelectedDate, id: \.id) { booking in
                        BookingRow(booking: booking)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
        }
        .padding(.vertical)
    }

    private var calendarDates: [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: viewModel.currentMonth) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let daysInMonth = calendar.range(of: .day, in: .month, for: viewModel.currentMonth)?.count ?? 0

        var dates: [Date?] = []

        // Add empty cells for days before the first of the month
        for _ in 1..<firstWeekday {
            dates.append(nil)
        }

        // Add all days in the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                dates.append(date)
            }
        }

        return dates
    }

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: viewModel.selectedDate)
    }
}

struct CalendarDayCell: View {
    let date: Date
    let bookingCount: Int
    let isSelected: Bool
    let isToday: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(textColor)

            if bookingCount > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<min(bookingCount, 3), id: \.self) { _ in
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.orange : Color.clear, lineWidth: 2)
        )
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .orange
        } else {
            return .primary
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return .orange
        } else {
            return Color(.systemGray6)
        }
    }
}

struct BookingRow: View {
    let booking: Booking

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(statusColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(booking.className)
                    .font(.subheadline.weight(.medium))

                Text(booking.formattedTimeRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: booking.statusIcon)
                .foregroundColor(statusColor)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }

    private var statusColor: Color {
        switch booking.status {
        case "confirmed": return .blue
        case "attended": return .green
        case "cancelled": return .red
        case "missed": return .orange
        default: return .gray
        }
    }
}

#Preview {
    CalendarGridView(viewModel: CalendarViewModel(bookingRepository: BookingRepository()))
}
