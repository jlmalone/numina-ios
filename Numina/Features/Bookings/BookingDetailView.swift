//
//  BookingDetailView.swift
//  Numina
//
//  Detailed booking view with actions
//

import SwiftUI

struct BookingDetailView: View {
    @Binding var booking: Booking
    @ObservedObject var viewModel: BookingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingCancelConfirmation = false
    @State private var showingSuccessMessage = false
    @State private var successMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Class Image
                    headerImage

                    // Status Badge
                    statusBadge

                    // Class Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text(booking.className)
                            .font(.title2.weight(.bold))

                        // Class Info Grid
                        VStack(spacing: 12) {
                            InfoRow(icon: "tag.fill", label: "Type", value: booking.classType)
                            InfoRow(icon: "calendar", label: "Date", value: booking.formattedDate)
                            InfoRow(icon: "clock", label: "Time", value: booking.formattedTimeRange)
                            InfoRow(icon: "hourglass", label: "Duration", value: "\(booking.duration) minutes")
                            InfoRow(icon: "location.fill", label: "Location", value: booking.locationName)
                            InfoRow(icon: "person.fill", label: "Trainer", value: booking.trainerName)

                            if booking.reminderEnabled, let reminderTime = booking.reminderTime {
                                InfoRow(icon: "bell.fill", label: "Reminder", value: "\(reminderTime) minutes before")
                            }
                        }
                    }
                    .padding()

                    // Actions
                    if booking.isUpcoming && booking.status == "confirmed" {
                        VStack(spacing: 12) {
                            // Mark Attended (if today)
                            if booking.isToday {
                                Button(action: {
                                    Task {
                                        let result = await viewModel.markAsAttended(id: booking.id)
                                        if result.success {
                                            successMessage = result.streakUpdated ? "Marked as attended! 🔥 \(result.newStreak ?? 0) day streak!" : "Marked as attended!"
                                            showingSuccessMessage = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                dismiss()
                                            }
                                        }
                                    }
                                }) {
                                    Label("Mark as Attended", systemImage: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal)
                            }

                            // Export to Calendar
                            Button(action: {
                                Task {
                                    let success = await viewModel.exportToCalendar(booking: booking)
                                    if success {
                                        successMessage = "Added to your calendar!"
                                        showingSuccessMessage = true
                                    }
                                }
                            }) {
                                Label("Add to Calendar", systemImage: "calendar.badge.plus")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)

                            // Cancel Booking
                            Button(action: {
                                showingCancelConfirmation = true
                            }) {
                                Label("Cancel Booking", systemImage: "xmark.circle")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .foregroundColor(.red)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Booking Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Cancel Booking?", isPresented: $showingCancelConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Yes, Cancel Booking", role: .destructive) {
                    Task {
                        let success = await viewModel.cancelBooking(id: booking.id)
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to cancel this booking?")
            }
            .alert("Success", isPresented: $showingSuccessMessage) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(successMessage)
            }
        }
    }

    private var headerImage: some View {
        Group {
            if let imageURL = booking.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                }
                .frame(height: 200)
                .clipped()
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                    )
            }
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: booking.statusIcon)
            Text(booking.status.capitalized)
                .font(.headline)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(statusColor)
        .cornerRadius(20)
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

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)

            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .fontWeight(.medium)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BookingDetailView(
        booking: .constant(Booking(
            id: "1",
            userId: "user1",
            classId: "class1",
            className: "Power Yoga Flow",
            classType: "Yoga",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            duration: 60,
            locationName: "Zen Studio",
            locationAddress: "123 Main St",
            trainerName: "Sarah Johnson",
            status: "confirmed"
        )),
        viewModel: BookingsViewModel(bookingRepository: BookingRepository())
    )
}
