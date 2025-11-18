//
//  GroupsView.swift
//  Numina
//
//  List view for groups discovery
//

import SwiftUI

struct GroupsView: View {
    @StateObject var viewModel: GroupsViewModel
    @State private var showingFilters = false
    @State private var showingCreateGroup = false
    @State private var selectedGroup: Group?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.groups.isEmpty {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.groups.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadGroups()
                        }
                    }
                } else if viewModel.groups.isEmpty {
                    EmptyGroupsView()
                } else {
                    groupListContent
                }
            }
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: viewModel.hasActiveFilters() ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateGroup = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search groups")
            .onChange(of: viewModel.searchText) { _, _ in
                Task {
                    await viewModel.loadGroups()
                }
            }
            .sheet(isPresented: $showingFilters) {
                GroupFiltersView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingCreateGroup) {
                CreateGroupView()
            }
            .sheet(item: $selectedGroup) { group in
                GroupDetailView(groupId: group.id)
            }
            .task {
                if viewModel.groups.isEmpty {
                    await viewModel.loadGroups()
                }
            }
        }
    }

    private var groupListContent: some View {
        List {
            ForEach(viewModel.filteredGroups, id: \.id) { group in
                GroupCard(group: group)
                    .onTapGesture {
                        selectedGroup = group
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshGroups()
        }
    }
}

struct EmptyGroupsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.5))

            Text("No Groups Found")
                .font(.title3.weight(.medium))

            Text("Try adjusting your filters or create a new group")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct GroupFiltersView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Size") {
                    HStack {
                        Text("Min Members")
                        Spacer()
                        TextField("Min", value: $viewModel.minSize, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    HStack {
                        Text("Max Members")
                        Spacer()
                        TextField("Max", value: $viewModel.maxSize, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("Location") {
                    Toggle("Use Current Location", isOn: $viewModel.useCurrentLocation)

                    if viewModel.useCurrentLocation {
                        VStack(alignment: .leading) {
                            Text("Radius: \(Int(viewModel.locationRadius)) miles")
                                .font(.subheadline)

                            Slider(value: $viewModel.locationRadius, in: 1...50, step: 1)
                        }
                    }
                }

                Section {
                    Button("Apply Filters") {
                        Task {
                            await viewModel.loadGroups()
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)

                    Button("Clear Filters") {
                        viewModel.clearFilters()
                        Task {
                            await viewModel.loadGroups()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
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

#Preview {
    GroupsView(viewModel: GroupsViewModel(groupRepository: GroupRepository()))
}
