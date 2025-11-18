//
//  ClassDetailView.swift
//  Numina
//
//  Detailed view for a fitness class
//

import SwiftUI
import MapKit

struct ClassDetailView: View {
    let fitnessClass: FitnessClass
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var region: MKCoordinateRegion

    init(fitnessClass: FitnessClass) {
        self.fitnessClass = fitnessClass
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: fitnessClass.latitude,
                longitude: fitnessClass.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Image
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
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(height: 200)
                        .clipped()
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        // Class Name and Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text(fitnessClass.name)
                                .font(.title.bold())

                            HStack {
                                Label(fitnessClass.classType, systemImage: "figure.run")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)

                                Spacer()

                                Text(fitnessClass.formattedPrice)
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                            }
                        }

                        Divider()

                        // Time and Date
                        VStack(alignment: .leading, spacing: 8) {
                            Label(fitnessClass.formattedDate, systemImage: "calendar")
                                .font(.subheadline)

                            Label(fitnessClass.formattedTimeRange, systemImage: "clock")
                                .font(.subheadline)

                            Label("\(fitnessClass.duration) minutes", systemImage: "timer")
                                .font(.subheadline)
                        }

                        Divider()

                        // Intensity
                        HStack {
                            Text("Intensity:")
                                .font(.subheadline.weight(.medium))

                            HStack(spacing: 4) {
                                ForEach(1...10, id: \.self) { level in
                                    Circle()
                                        .fill(level <= fitnessClass.intensity ? Color.orange : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                            }

                            Text(fitnessClass.intensityDescription)
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }

                        Divider()

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About This Class")
                                .font(.headline)

                            Text(fitnessClass.classDescription)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        // Trainer Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Trainer")
                                .font(.headline)

                            HStack(spacing: 12) {
                                // Trainer Photo
                                if let photoURL = fitnessClass.trainerPhotoURL {
                                    AsyncImage(url: URL(string: photoURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .frame(width: 60, height: 60)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(fitnessClass.trainerName)
                                        .font(.headline)

                                    if let bio = fitnessClass.trainerBio {
                                        Text(bio)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }

                                Spacer()
                            }
                        }

                        Divider()

                        // Location
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Location")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(fitnessClass.locationName)
                                    .font(.subheadline.weight(.medium))

                                Text(fitnessClass.locationAddress)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            // Map
                            Map(coordinateRegion: $region, annotationItems: [fitnessClass]) { location in
                                MapMarker(
                                    coordinate: CLLocationCoordinate2D(
                                        latitude: location.latitude,
                                        longitude: location.longitude
                                    ),
                                    tint: .orange
                                )
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                            .allowsHitTesting(false)
                        }

                        Divider()

                        // Availability
                        if let spotsAvailable = fitnessClass.spotsAvailable,
                           let totalSpots = fitnessClass.totalSpots {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.orange)

                                Text("\(spotsAvailable) of \(totalSpots) spots available")
                                    .font(.subheadline)
                            }
                        }

                        // Action Buttons
                        VStack(spacing: 12) {
                            // Book Button
                            Button(action: {
                                if let url = URL(string: fitnessClass.bookingURL) {
                                    openURL(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Book on \(fitnessClass.provider)")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }

                            // Find Partner Button (Future Feature)
                            Button(action: {
                                // Future feature
                            }) {
                                HStack {
                                    Image(systemName: "person.2")
                                    Text("Find Workout Partner")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                            }
                            .disabled(true)
                            .opacity(0.6)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension FitnessClass: Identifiable {}

#Preview {
    ClassDetailView(
        fitnessClass: FitnessClass(
            id: "1",
            name: "Power Yoga Flow",
            classDescription: "A dynamic vinyasa-style yoga class that builds strength and flexibility.",
            classType: "Yoga",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            duration: 60,
            intensity: 7,
            price: 25.0,
            locationName: "Zen Studio",
            locationAddress: "123 Main St, San Francisco, CA",
            latitude: 37.7749,
            longitude: -122.4194,
            trainerName: "Sarah Johnson",
            trainerBio: "Certified yoga instructor with 10+ years experience",
            provider: "ClassPass",
            bookingURL: "https://classpass.com",
            spotsAvailable: 5,
            totalSpots: 20
        )
    )
}
