//
//  GroupMembersView.swift
//  Numina
//
//  View for displaying group members
//

import SwiftUI

struct GroupMembersView: View {
    @StateObject private var viewModel: GroupMembersViewModel
    @Environment(\.dismiss) var dismiss

    init(groupId: String) {
        _viewModel = StateObject(wrappedValue: GroupMembersViewModel(
            groupId: groupId,
            groupRepository: GroupRepository()
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.members.isEmpty {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.members.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadMembers()
                        }
                    }
                } else if viewModel.members.isEmpty {
                    EmptyMembersView()
                } else {
                    membersList
                }
            }
            .navigationTitle("Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadMembers()
            }
        }
    }

    private var membersList: some View {
        List {
            if !viewModel.admins.isEmpty {
                Section("Admins") {
                    ForEach(viewModel.admins, id: \.id) { member in
                        MemberRow(member: member)
                    }
                }
            }

            Section("Members") {
                ForEach(viewModel.regularMembers, id: \.id) { member in
                    MemberRow(member: member)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.loadMembers()
        }
    }
}

struct MemberRow: View {
    let member: GroupMember

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
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
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                    )
            }

            // Member Info
            VStack(alignment: .leading, spacing: 4) {
                Text(member.userName)
                    .font(.body)

                HStack(spacing: 4) {
                    if member.role == "admin" {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }

                    Text("Joined \(member.joinedAt, format: .dateTime.month().day().year())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if member.role == "admin" {
                Text("Admin")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyMembersView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.5))

            Text("No Members")
                .font(.title3.weight(.medium))

            Text("Be the first to join this group")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

@MainActor
final class GroupMembersViewModel: ObservableObject {
    @Published var members: [GroupMember] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let groupId: String
    private let groupRepository: GroupRepository

    init(groupId: String, groupRepository: GroupRepository) {
        self.groupId = groupId
        self.groupRepository = groupRepository
    }

    func loadMembers() async {
        isLoading = true
        errorMessage = nil

        do {
            members = try await groupRepository.getGroupMembers(groupId: groupId)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    var admins: [GroupMember] {
        members.filter { $0.role == "admin" }
    }

    var regularMembers: [GroupMember] {
        members.filter { $0.role == "member" }
    }
}

#Preview {
    GroupMembersView(groupId: "group123")
}
