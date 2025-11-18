//
//  ProfileView.swift
//  Numina
//
//  User profile view
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if let user = viewModel.user {
                    profileContent(user: user)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadProfile()
                        }
                    }
                } else {
                    EmptyProfileView()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.editProfile()
                        }) {
                            Label("Edit Profile", systemImage: "pencil")
                        }

                        Divider()

                        Button(role: .destructive, action: {
                            authViewModel.logout()
                        }) {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.orange)
                    }
                }
            }
            .task {
                if viewModel.user == nil {
                    await viewModel.loadProfile()
                }
            }
            .sheet(isPresented: $viewModel.showingProfileSetup) {
                ProfileSetupCoordinator(
                    viewModel: ProfileSetupViewModel(
                        userRepository: UserRepository(),
                        currentUser: viewModel.user
                    )
                )
            }
        }
    }

    @ViewBuilder
    private func profileContent(user: User) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Photo
                    if let photoURL = user.photoURL {
                        AsyncImage(url: URL(string: photoURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 120, height: 120)
                    }

                    // Name
                    Text(user.name)
                        .font(.title.bold())

                    // Bio
                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 24)

                Divider()
                    .padding(.horizontal)

                // Profile Details
                VStack(spacing: 16) {
                    // Fitness Level
                    ProfileRow(
                        icon: "chart.bar.fill",
                        title: "Fitness Level",
                        value: "\(user.fitnessLevel)/10"
                    )

                    // Interests
                    ProfileRow(
                        icon: "heart.fill",
                        title: "Interests",
                        value: viewModel.fitnessInterestsText
                    )

                    // Location
                    ProfileRow(
                        icon: "location.fill",
                        title: "Location",
                        value: viewModel.locationText
                    )

                    // Availability
                    ProfileRow(
                        icon: "clock.fill",
                        title: "Availability",
                        value: viewModel.availabilityText
                    )
                }
                .padding(.horizontal)

                // Availability Details
                if !user.availability.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Schedule")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(user.availability, id: \.dayOfWeek) { slot in
                                HStack {
                                    Text(slot.dayName)
                                        .font(.subheadline.weight(.medium))

                                    Spacer()

                                    Text("\(slot.startTime) - \(slot.endTime)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }

                Spacer()
            }
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.body)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EmptyProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))

            Text("Profile Not Found")
                .font(.title3.weight(.medium))

            Text("Please try logging in again")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel(userRepository: UserRepository()),
        authViewModel: AuthViewModel(userRepository: UserRepository())
    )
}
