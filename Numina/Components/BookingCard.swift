//
//  BookingCard.swift
//  Numina
//
//  Reusable booking card for list display
//

import SwiftUI

struct BookingCard: View {
    let booking: Booking

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with image and status
            ZStack(alignment: .topTrailing) {
                if let imageURL = booking.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "calendar")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 120)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [statusGradientColors.0, statusGradientColors.1],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "calendar")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.8))
                        )
                }

                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: booking.statusIcon)
                        .font(.caption2)
                    Text(booking.status.capitalized)
                        .font(.caption.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor)
                .cornerRadius(8)
                .padding(8)
            }

            // Booking Info
            VStack(alignment: .leading, spacing: 8) {
                // Class Name and Type
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(booking.className)
                            .font(.headline)
                            .lineLimit(2)

                        Text(booking.classType)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                // Date and Time
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(booking.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(booking.formattedTimeRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(booking.locationName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // Trainer and Reminder
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(booking.trainerName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if booking.reminderEnabled {
                        HStack(spacing: 4) {
                            Image(systemName: "bell.fill")
                                .font(.caption)
                                .foregroundColor(.orange)

                            if let reminderTime = booking.reminderTime {
                                Text("\(reminderTime)m")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var statusColor: Color {
        switch booking.status {
        case "confirmed":
            return .blue
        case "attended":
            return .green
        case "cancelled":
            return .red
        case "missed":
            return .orange
        default:
            return .gray
        }
    }

    private var statusGradientColors: (Color, Color) {
        switch booking.status {
        case "confirmed":
            return (.blue.opacity(0.3), .cyan.opacity(0.3))
        case "attended":
            return (.green.opacity(0.3), .mint.opacity(0.3))
        case "cancelled":
            return (.red.opacity(0.3), .pink.opacity(0.3))
        case "missed":
            return (.orange.opacity(0.3), .yellow.opacity(0.3))
        default:
            return (.gray.opacity(0.3), .gray.opacity(0.3))
        }
    }
}

#Preview {
    BookingCard(
        booking: Booking(
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
            status: "confirmed",
            reminderEnabled: true,
            reminderTime: 60
        )
    )
    .padding()
}
