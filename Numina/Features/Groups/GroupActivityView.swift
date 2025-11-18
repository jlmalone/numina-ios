//
//  GroupActivityView.swift
//  Numina
//
//  Detail view for a group activity with RSVP
//

import SwiftUI

struct GroupActivityView: View {
    let groupId: String
    @State var activity: GroupActivity
    @State private var selectedRSVP: String?
    @State private var isSubmittingRSVP = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss

    private let groupRepository = GroupRepository()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    activityHeader

                    // Description
                    descriptionSection

                    // Details
                    detailsSection

                    // RSVP Section
                    rsvpSection

                    // Linked Class (if available)
                    if activity.fitnessClassId != nil {
                        linkedClassSection
                    }
                }
                .padding()
            }
            .navigationTitle("Activity Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
        }
        .onAppear {
            selectedRSVP = activity.userRSVP
        }
    }

    private var activityHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(activityColor.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: activityIcon)
                        .font(.system(size: 28))
                        .foregroundColor(activityColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.title2.bold())

                    Text(activity.activityType.capitalized)
                        .font(.subheadline)
                        .foregroundColor(activityColor)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)

            Text(activity.activityDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            if let scheduledTime = activity.formattedScheduledTime {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Date & Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(scheduledTime)
                            .font(.subheadline)
                    }
                }
            }

            if let locationName = activity.locationName {
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(locationName)
                            .font(.subheadline)
                    }
                }
            }

            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Attendance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(activity.formattedRSVPCount)
                        .font(.subheadline)

                    if activity.isFull {
                        Text("Activity is full")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var rsvpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your RSVP")
                .font(.headline)

            HStack(spacing: 12) {
                RSVPButton(
                    title: "Going",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    isSelected: selectedRSVP == "yes"
                ) {
                    submitRSVP("yes")
                }

                RSVPButton(
                    title: "Maybe",
                    icon: "questionmark.circle.fill",
                    color: .orange,
                    isSelected: selectedRSVP == "maybe"
                ) {
                    submitRSVP("maybe")
                }

                RSVPButton(
                    title: "Can't Go",
                    icon: "xmark.circle.fill",
                    color: .red,
                    isSelected: selectedRSVP == "no"
                ) {
                    submitRSVP("no")
                }
            }

            if isSubmittingRSVP {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var linkedClassSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Linked Fitness Class")
                .font(.headline)

            Button(action: {
                // Navigate to class details
            }) {
                HStack {
                    Image(systemName: "figure.run")
                        .foregroundColor(.orange)

                    Text("View Class Details")
                        .font(.subheadline)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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

    private func submitRSVP(_ response: String) {
        Task {
            isSubmittingRSVP = true
            errorMessage = nil

            do {
                try await groupRepository.rsvpActivity(
                    groupId: groupId,
                    activityId: activity.id,
                    response: response
                )

                // Update local state
                let oldRSVP = activity.userRSVP
                activity.userRSVP = response
                selectedRSVP = response

                // Update RSVP count
                if oldRSVP == "yes" && response != "yes" {
                    activity.rsvpCount = max(0, activity.rsvpCount - 1)
                } else if oldRSVP != "yes" && response == "yes" {
                    activity.rsvpCount += 1
                }
            } catch let error as APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = error.localizedDescription
            }

            isSubmittingRSVP = false
        }
    }
}

struct RSVPButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)

                Text(title)
                    .font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? color.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? color : .secondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    GroupActivityView(
        groupId: "group123",
        activity: GroupActivity(
            id: "activity1",
            groupId: "group123",
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
}
