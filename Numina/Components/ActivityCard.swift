//
//  ActivityCard.swift
//  Numina
//
//  Reusable activity card for group activities
//

import SwiftUI

struct ActivityCard: View {
    let activity: GroupActivity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                // Activity Icon
                ZStack {
                    Circle()
                        .fill(activityColor.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: activityIcon)
                        .font(.system(size: 20))
                        .foregroundColor(activityColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.headline)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.caption2)
                        Text(activity.activityType.capitalized)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }

                Spacer()

                // RSVP Status
                if let rsvp = activity.userRSVP {
                    rsvpBadge(for: rsvp)
                }
            }

            // Description
            Text(activity.activityDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Divider()

            // Details
            VStack(spacing: 8) {
                // Date and Time
                if let formattedTime = activity.formattedScheduledTime {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(formattedTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Location
                if let locationName = activity.locationName {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(locationName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // RSVP Count
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(activity.formattedRSVPCount)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if activity.isFull {
                        Text("• Full")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.orange)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private var activityColor: Color {
        switch activity.activityType.lowercased() {
        case "workout", "fitness":
            return .orange
        case "social":
            return .purple
        case "event":
            return .blue
        default:
            return .green
        }
    }

    private var activityIcon: String {
        switch activity.activityType.lowercased() {
        case "workout", "fitness":
            return "figure.run"
        case "social":
            return "person.3.fill"
        case "event":
            return "calendar.badge.clock"
        default:
            return "star.fill"
        }
    }

    private func rsvpBadge(for response: String) -> some View {
        let config = rsvpConfig(for: response)

        return HStack(spacing: 4) {
            Image(systemName: config.icon)
                .font(.caption2)
            Text(config.text)
                .font(.caption2.weight(.medium))
        }
        .foregroundColor(config.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(config.color.opacity(0.15))
        .cornerRadius(6)
    }

    private func rsvpConfig(for response: String) -> (icon: String, text: String, color: Color) {
        switch response.lowercased() {
        case "yes":
            return ("checkmark.circle.fill", "Going", .green)
        case "no":
            return ("xmark.circle.fill", "Not Going", .red)
        case "maybe":
            return ("questionmark.circle.fill", "Maybe", .orange)
        default:
            return ("circle", "Unknown", .gray)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ActivityCard(
            activity: GroupActivity(
                id: "1",
                groupId: "group1",
                title: "Morning Run - 5K",
                activityDescription: "Join us for a refreshing 5K run through the park. All paces welcome!",
                activityType: "workout",
                scheduledTime: Date().addingTimeInterval(86400),
                locationName: "Central Park, North Meadow",
                maxParticipants: 20,
                rsvpCount: 12,
                userRSVP: "yes",
                createdBy: "user123"
            )
        )

        ActivityCard(
            activity: GroupActivity(
                id: "2",
                groupId: "group1",
                title: "Post-Workout Coffee",
                activityDescription: "Grab coffee together after the morning workout session.",
                activityType: "social",
                scheduledTime: Date().addingTimeInterval(172800),
                locationName: "Starbucks, Main St",
                rsvpCount: 8,
                userRSVP: "maybe",
                createdBy: "user456"
            )
        )
    }
    .padding()
}
