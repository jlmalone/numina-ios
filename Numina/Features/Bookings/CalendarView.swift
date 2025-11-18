//
//  CalendarView.swift
//  Numina
//
//  Calendar view with month/week/day modes
//

import SwiftUI

struct CalendarView: View {
    @StateObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // View Mode Picker
            Picker("View Mode", selection: $viewModel.calendarViewMode) {
                Text("Month").tag(CalendarViewModel.CalendarViewMode.month)
                Text("Week").tag(CalendarViewModel.CalendarViewMode.week)
                Text("Day").tag(CalendarViewModel.CalendarViewMode.day)
            }
            .pickerStyle(.segmented)
            .padding()

            // Calendar Content
            ScrollView {
                switch viewModel.calendarViewMode {
                case .month:
                    CalendarGridView(viewModel: viewModel)
                case .week:
                    WeekScrollView(viewModel: viewModel)
                case .day:
                    DayScheduleView(viewModel: viewModel)
                }
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Today") {
                    viewModel.navigateToToday()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.loadMonthData(month: viewModel.currentMonth)
        }
    }
}

#Preview {
    NavigationStack {
        CalendarView(viewModel: CalendarViewModel(bookingRepository: BookingRepository()))
    }
}
