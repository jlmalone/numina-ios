//
//  ClassListView.swift
//  Numina
//
//  List view for fitness classes
//

import SwiftUI

struct ClassListView: View {
    @StateObject var viewModel: ClassViewModel
    @State private var showingFilters = false
    @State private var selectedClass: FitnessClass?
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                OfflineBanner()

                ZStack {
                    if viewModel.isLoading && viewModel.classes.isEmpty {
                        skeletonLoadingView
                    } else if let errorMessage = viewModel.errorMessage, viewModel.classes.isEmpty {
                        if !networkMonitor.isConnected {
                            NetworkErrorView {
                                Task {
                                    await viewModel.loadClasses()
                                }
                            }
                        } else {
                            ErrorView(message: errorMessage) {
                                Task {
                                    await viewModel.loadClasses()
                                }
                            }
                        }
                    } else if viewModel.classes.isEmpty {
                        EmptyStateView.noClasses {
                            viewModel.clearFilters()
                        }
                    } else {
                        classListContent
                    }
                }
            }
            .navigationTitle("Discover Classes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticFeedback.shared.buttonPress()
                        showingFilters = true
                    }) {
                        Image(systemName: viewModel.hasActiveFilters() ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(.orange)
                    }
                    .accessibilityLabel(viewModel.hasActiveFilters() ? "Filters active" : "Show filters")
                    .accessibilityHint("Opens filter options for classes")
                }
            }
            .sheet(isPresented: $showingFilters) {
                ClassFiltersView(viewModel: viewModel)
            }
            .sheet(item: $selectedClass) { fitnessClass in
                ClassDetailView(fitnessClass: fitnessClass)
            }
            .task {
                if viewModel.classes.isEmpty {
                    await viewModel.loadClasses()
                }
            }
        }
    }

    private var classListContent: some View {
        List {
            ForEach(viewModel.filteredClasses, id: \.id) { fitnessClass in
                ClassCard(fitnessClass: fitnessClass)
                    .onTapGesture {
                        HapticFeedback.shared.light()
                        selectedClass = fitnessClass
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .listStyle(.plain)
        .refreshable {
            HapticFeedback.shared.refreshStart()
            await viewModel.refreshClasses()
            HapticFeedback.shared.refreshComplete()
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.filteredClasses.count)
    }

    private var skeletonLoadingView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonClassCard()
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    ClassListView(viewModel: ClassViewModel(classRepository: ClassRepository()))
}
