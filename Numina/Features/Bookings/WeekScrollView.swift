//
//  WeekScrollView.swift
//  Numina
//
//  Horizontal scrolling week view
//

import SwiftUI

struct WeekScrollView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Week Header
            Text("Week of \(weekStartDate)")
                .font(.headline)
                .padding(.top)

            // Week Day Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.currentWeekDates, id: \.self) { date in
                        WeekDayCell(
                            date: date,
                            bookingCount: viewModel.bookingCount(on: date),
                            isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                            isToday: Calendar.current.isDateInToday(date)
                        )
                        .onTapGesture {
                            viewModel.selectedDate = date
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Selected Day's Bookings
            if viewModel.bookingsForSelectedDate.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("No bookings for \(shortDate)")
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.bookingsForSelectedDate, id: \.id) { booking in
                            BookingCard(booking: booking)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }

    private var weekStartDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        if let weekStart = viewModel.currentWeekDates.first {
            return formatter.string(from: weekStart)
        }

        return ""
    }

    private var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: viewModel.selectedDate)
    }
}

struct WeekDayCell: View {
    let date: Date
    let bookingCount: Int
    let isSelected: Bool
    let isToday: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(weekdayName)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                .foregroundColor(textColor)

            if bookingCount > 0 {
                Text("\(bookingCount)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(Color.orange)
                    .clipShape(Circle())
            } else {
                Color.clear.frame(width: 18, height: 18)
            }
        }
        .frame(width: 60)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Color.orange : Color.clear, lineWidth: 2)
        )
    }

    private var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
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

#Preview {
    WeekScrollView(viewModel: CalendarViewModel(bookingRepository: BookingRepository()))
}
