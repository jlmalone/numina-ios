//
//  LocationStep.swift
//  Numina
//
//  Location step in profile setup
//

import SwiftUI

struct LocationStep: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    @StateObject private var locationManager = LocationManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Where do you work out?")
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                // Current Location Button
                if !locationManager.isAuthorized {
                    VStack(spacing: 16) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)

                        Text("Enable location access to find classes near you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Enable Location") {
                            locationManager.requestPermission()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding(.vertical, 24)
                } else {
                    Button(action: {
                        locationManager.requestLocation()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Use Current Location")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                    }

                    if let lat = locationManager.latitude, let lon = locationManager.longitude {
                        Text("Location: \(lat, specifier: "%.4f"), \(lon, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Text("OR")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)

                // Manual Location Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter Location Manually *")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)

                    TextField("City, State or Zip Code", text: $viewModel.locationName)
                        .textFieldStyle(.plain)
                        .textContentType(.addressCity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                if let errorMessage = locationManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Text("We'll use this to help you discover classes nearby")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
        .onChange(of: locationManager.location) { oldValue, newValue in
            if let location = newValue {
                viewModel.latitude = location.coordinate.latitude
                viewModel.longitude = location.coordinate.longitude
                viewModel.locationName = "Current Location"
            }
        }
    }
}

#Preview {
    LocationStep(viewModel: ProfileSetupViewModel(userRepository: UserRepository()))
}
