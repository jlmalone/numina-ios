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
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                OfflineBanner()

                ZStack {
                    if viewModel.isLoading && viewModel.groups.isEmpty {
                        skeletonLoadingView
                    } else if let errorMessage = viewModel.errorMessage, viewModel.groups.isEmpty {
                        if !networkMonitor.isConnected {
                            NetworkErrorView {
                                Task {
                                    await viewModel.loadGroups()
                                }
                            }
                        } else {
                            ErrorView(message: errorMessage) {
                                Task {
                                    await viewModel.loadGroups()
                                }
                            }
                        }
                    } else if viewModel.groups.isEmpty {
                        EmptyStateView.noGroups {
                            HapticFeedback.shared.buttonPress()
                            showingCreateGroup = true
                        }
                    } else {
                        groupListContent
                    }
                }
            }
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        HapticFeedback.shared.buttonPress()
                        showingFilters = true
                    }) {
                        Image(systemName: viewModel.hasActiveFilters() ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel(viewModel.hasActiveFilters() ? "Filters active" : "Show filters")
                    .accessibilityHint("Opens filter options for groups")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticFeedback.shared.buttonPress()
                        showingCreateGroup = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Create group")
                    .accessibilityHint("Opens form to create a new group")
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
                        HapticFeedback.shared.light()
                        selectedGroup = group
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .listStyle(.plain)
        .refreshable {
            HapticFeedback.shared.refreshStart()
            await viewModel.refreshGroups()
            HapticFeedback.shared.refreshComplete()
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.filteredGroups.count)
    }

    private var skeletonLoadingView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    SkeletonGroupCard()
                }
            }
            .padding(16)
        }
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
                        HapticFeedback.shared.buttonPress()
                        Task {
                            await viewModel.loadGroups()
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)

                    Button("Clear Filters") {
                        HapticFeedback.shared.buttonPress()
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
                        HapticFeedback.shared.buttonPress()
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
