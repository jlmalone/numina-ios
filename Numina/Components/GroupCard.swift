//
//  GroupCard.swift
//  Numina
//
//  Reusable group card for list display
//

import SwiftUI

struct GroupCard: View {
    let group: Group

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with image
            ZStack(alignment: .topTrailing) {
                if let imageURL = group.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 140)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        )
                }

                // Category Badge
                Text(group.category)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(8)
            }

            // Group Info
            VStack(alignment: .leading, spacing: 8) {
                // Name and Join Status
                HStack(alignment: .top) {
                    Text(group.name)
                        .font(.headline)
                        .lineLimit(2)

                    Spacer()

                    if group.isJoined {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }

                // Description
                Text(group.groupDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Member Count
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(group.formattedMemberCount)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if group.isFull {
                        Text("• Full")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.orange)
                    }
                }

                // Location (if available)
                if let locationName = group.locationName {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(locationName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                // Privacy Badge
                HStack {
                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: group.privacy == "public" ? "globe" : "lock.fill")
                            .font(.caption2)
                        Text(group.privacy.capitalized)
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundColor(group.privacy == "public" ? .blue : .orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (group.privacy == "public" ? Color.blue : Color.orange)
                            .opacity(0.15)
                    )
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    GroupCard(
        group: Group(
            id: "1",
            name: "Morning Runners Club",
            groupDescription: "Join us for early morning runs around the city. All levels welcome!",
            category: "Running",
            privacy: "public",
            memberCount: 24,
            maxMembers: 50,
            locationName: "Central Park",
            latitude: 40.7829,
            longitude: -73.9654,
            createdBy: "user123",
            isJoined: true
        )
    )
    .padding()
}
