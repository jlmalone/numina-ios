//
//  BookingsView.swift
//  Numina
//
//  Main bookings list view
//

import SwiftUI

struct BookingsView: View {
    @StateObject var viewModel: BookingsViewModel
    @State private var selectedBooking: Booking?
    @State private var showingStats = false
    @State private var showingCalendar = false

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.bookings.isEmpty {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.bookings.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadBookings()
                        }
                    }
                } else if viewModel.bookings.isEmpty {
                    EmptyBookingsView()
                } else {
                    bookingsListContent
                }
            }
            .navigationTitle("My Bookings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingCalendar = true
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingStats = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(item: $selectedBooking) { booking in
                BookingDetailView(booking: binding(for: booking), viewModel: viewModel)
            }
            .sheet(isPresented: $showingStats) {
                NavigationStack {
                    AttendanceStatsView(
                        viewModel: AttendanceStatsViewModel(
                            bookingRepository: BookingRepository()
                        )
                    )
                }
            }
            .sheet(isPresented: $showingCalendar) {
                NavigationStack {
                    CalendarView(
                        viewModel: CalendarViewModel(
                            bookingRepository: BookingRepository()
                        )
                    )
                }
            }
            .task {
                if viewModel.bookings.isEmpty {
                    await viewModel.loadBookings()
                }
            }
        }
    }

    private var bookingsListContent: some View {
        List {
            // Filter Toggle
            Picker("Filter", selection: $viewModel.showUpcomingOnly) {
                Text("Upcoming").tag(true)
                Text("All").tag(false)
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .onChange(of: viewModel.showUpcomingOnly) { _ in
                Task {
                    await viewModel.loadBookings()
                }
            }

            // Today's Bookings Section
            if !viewModel.todayBookings.isEmpty {
                Section(header: Text("Today").font(.headline)) {
                    ForEach(viewModel.todayBookings, id: \.id) { booking in
                        BookingCard(booking: booking)
                            .onTapGesture {
                                selectedBooking = booking
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                }
            }

            // Upcoming Bookings Section
            if !viewModel.upcomingBookings.isEmpty {
                Section(header: Text(viewModel.todayBookings.isEmpty ? "Upcoming" : "Later").font(.headline)) {
                    ForEach(viewModel.upcomingBookings.filter { !$0.isToday }, id: \.id) { booking in
                        BookingCard(booking: booking)
                            .onTapGesture {
                                selectedBooking = booking
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                }
            }

            // Past Bookings Section
            if !viewModel.showUpcomingOnly && !viewModel.pastBookings.isEmpty {
                Section(header: Text("Past").font(.headline)) {
                    ForEach(viewModel.pastBookings.prefix(10), id: \.id) { booking in
                        BookingCard(booking: booking)
                            .opacity(0.7)
                            .onTapGesture {
                                selectedBooking = booking
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshBookings()
        }
    }

    private func binding(for booking: Booking) -> Binding<Booking> {
        guard let index = viewModel.bookings.firstIndex(where: { $0.id == booking.id }) else {
            return .constant(booking)
        }

        return Binding(
            get: { viewModel.bookings[index] },
            set: { viewModel.bookings[index] = $0 }
        )
    }
}

struct EmptyBookingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))

            Text("No Bookings Yet")
                .font(.title3.weight(.medium))

            Text("Book your first class to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    BookingsView(viewModel: BookingsViewModel(bookingRepository: BookingRepository()))
}
