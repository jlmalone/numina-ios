//
//  GroupDetailView.swift
//  Numina
//
//  Detail view for a specific group
//

import SwiftUI

struct GroupDetailView: View {
    @StateObject private var viewModel: GroupDetailViewModel
    @State private var showingMembers = false
    @State private var showingCreateActivity = false
    @State private var selectedActivity: GroupActivity?
    @Environment(\.dismiss) var dismiss

    init(groupId: String) {
        _viewModel = StateObject(wrappedValue: GroupDetailViewModel(
            groupId: groupId,
            groupRepository: GroupRepository()
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.group == nil {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.group == nil {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadGroupDetails()
                        }
                    }
                } else if let group = viewModel.group {
                    ScrollView {
                        VStack(spacing: 20) {
                            groupHeaderSection(group: group)
                            groupInfoSection(group: group)
                            membersSection
                            activitiesSection
                        }
                    }
                }
            }
            .navigationTitle("Group Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingMembers) {
                GroupMembersView(groupId: viewModel.groupId)
            }
            .sheet(isPresented: $showingCreateActivity) {
                CreateActivityView(groupId: viewModel.groupId)
            }
            .sheet(item: $selectedActivity) { activity in
                GroupActivityView(groupId: viewModel.groupId, activity: activity)
            }
            .task {
                await viewModel.loadGroupDetails()
                await viewModel.loadMembers()
                await viewModel.loadActivities()
            }
        }
    }

    private func groupHeaderSection(group: Group) -> some View {
        VStack(spacing: 0) {
            // Cover Image
            if let imageURL = group.imageURL {
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
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                    )
            }

            // Group Name and Category
            VStack(alignment: .leading, spacing: 8) {
                Text(group.name)
                    .font(.title2.bold())

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.caption)
                        Text(group.category)
                            .font(.subheadline)
                    }
                    .foregroundColor(.blue)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: group.privacy == "public" ? "globe" : "lock.fill")
                            .font(.caption)
                        Text(group.privacy.capitalized)
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }

                // Join/Leave Button
                Button(action: {
                    Task {
                        if group.isJoined {
                            await viewModel.leaveGroup()
                        } else {
                            await viewModel.joinGroup()
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: group.isJoined ? "checkmark.circle.fill" : "plus.circle.fill")
                        Text(group.isJoined ? "Leave Group" : "Join Group")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(group.isJoined ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(group.isFull && !group.isJoined)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.top)
    }

    private func groupInfoSection(group: Group) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)

            Text(group.groupDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            // Stats
            HStack(spacing: 20) {
                StatItem(icon: "person.2.fill", value: "\(group.memberCount)", label: "Members")

                if let locationName = group.locationName {
                    StatItem(icon: "location.fill", value: locationName, label: "Location")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Members")
                    .font(.headline)

                Spacer()

                Button("See All") {
                    showingMembers = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            if viewModel.isLoadingMembers {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if viewModel.members.isEmpty {
                Text("No members yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.members.prefix(10), id: \.id) { member in
                            MemberAvatarView(member: member)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Activities")
                    .font(.headline)

                Spacer()

                if viewModel.group?.isJoined == true {
                    Button(action: {
                        showingCreateActivity = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }

            if viewModel.isLoadingActivities {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if viewModel.upcomingActivities.isEmpty {
                Text("No upcoming activities")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.upcomingActivities, id: \.id) { activity in
                    ActivityCard(activity: activity)
                        .onTapGesture {
                            selectedActivity = activity
                        }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline.bold())
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct MemberAvatarView: View {
    let member: GroupMember

    var body: some View {
        VStack(spacing: 4) {
            if let photoURL = member.userPhotoURL {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                    )
            }

            Text(member.userName)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 60)
        }
    }
}

#Preview {
    GroupDetailView(groupId: "group123")
}
