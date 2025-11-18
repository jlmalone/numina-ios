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

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.classes.isEmpty {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.classes.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadClasses()
                        }
                    }
                } else if viewModel.classes.isEmpty {
                    EmptyClassesView()
                } else {
                    classListContent
                }
            }
            .navigationTitle("Discover Classes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: viewModel.hasActiveFilters() ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(.orange)
                    }
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
                        selectedClass = fitnessClass
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshClasses()
        }
    }
}

struct EmptyClassesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))

            Text("No Classes Found")
                .font(.title3.weight(.medium))

            Text("Try adjusting your filters or check back later")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ClassListView(viewModel: ClassViewModel(classRepository: ClassRepository()))
}
