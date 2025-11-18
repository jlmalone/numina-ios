//
//  DayScheduleView.swift
//  Numina
//
//  Day schedule view with timeline
//

import SwiftUI

struct DayScheduleView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Date Navigator
            HStack {
                Button(action: {
                    if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) {
                        viewModel.selectedDate = previousDay
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.orange)
                }

                Spacer()

                Text(formattedSelectedDate)
                    .font(.title3.weight(.bold))

                Spacer()

                Button(action: {
                    if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) {
                        viewModel.selectedDate = nextDay
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)

            // Day's Bookings
            if viewModel.bookingsForSelectedDate.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("No bookings for this day")
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
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

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: viewModel.selectedDate)
    }
}

#Preview {
    DayScheduleView(viewModel: CalendarViewModel(bookingRepository: BookingRepository()))
}
