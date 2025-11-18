//
//  ClassCard.swift
//  Numina
//
//  Reusable class card for list display
//

import SwiftUI

struct ClassCard: View {
    let fitnessClass: FitnessClass

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with image
            ZStack(alignment: .topTrailing) {
                if let imageURL = fitnessClass.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "figure.run")
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
                                colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: "figure.run")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                        )
                }

                // Class Type Badge
                Text(fitnessClass.classType)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .cornerRadius(8)
                    .padding(8)
            }

            // Class Info
            VStack(alignment: .leading, spacing: 8) {
                // Name and Price
                HStack(alignment: .top) {
                    Text(fitnessClass.name)
                        .font(.headline)
                        .lineLimit(2)

                    Spacer()

                    Text(fitnessClass.formattedPrice)
                        .font(.headline)
                        .foregroundColor(.orange)
                }

                // Date and Time
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(fitnessClass.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(fitnessClass.formattedTimeRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(fitnessClass.locationName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // Trainer and Intensity
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(fitnessClass.trainerName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Intensity indicator
                    HStack(spacing: 2) {
                        ForEach(1...3, id: \.self) { level in
                            Rectangle()
                                .fill(level <= (fitnessClass.intensity / 3) ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: 4, height: level * 4)
                        }
                    }

                    Text(fitnessClass.intensityDescription)
                        .font(.caption)
                        .foregroundColor(.orange)
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
    ClassCard(
        fitnessClass: FitnessClass(
            id: "1",
            name: "Power Yoga Flow",
            classDescription: "A dynamic vinyasa-style yoga class",
            classType: "Yoga",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            duration: 60,
            intensity: 7,
            price: 25.0,
            locationName: "Zen Studio",
            locationAddress: "123 Main St",
            latitude: 37.7749,
            longitude: -122.4194,
            trainerName: "Sarah Johnson",
            provider: "ClassPass",
            bookingURL: "https://classpass.com"
        )
    )
    .padding()
}
