//
//  DiscoverFiltersView.swift
//  Numina
//
//  Filters for user discovery
//

import SwiftUI

struct DiscoverFiltersView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Fitness Interests
                Section("Fitness Interests") {
                    ForEach(viewModel.fitnessInterests, id: \.self) { interest in
                        Toggle(interest, isOn: Binding(
                            get: { viewModel.selectedInterests.contains(interest) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedInterests.append(interest)
                                } else {
                                    viewModel.selectedInterests.removeAll { $0 == interest }
                                }
                            }
                        ))
                    }
                }

                // Fitness Level
                Section("Fitness Level") {
                    Picker("Level", selection: $viewModel.selectedFitnessLevel) {
                        Text("Any").tag(nil as Int?)
                        ForEach(1...10, id: \.self) { level in
                            Text("Level \(level)").tag(level as Int?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Location
                Section("Location") {
                    Toggle("Use Location Filter", isOn: $viewModel.useLocationFilter)

                    if viewModel.useLocationFilter {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Radius: \(Int(viewModel.locationRadius)) miles")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Slider(value: $viewModel.locationRadius, in: 1...50, step: 1)
                        }
                    }
                }

                // Actions
                Section {
                    Button(action: {
                        viewModel.clearSearch()
                        dismiss()
                    }) {
                        Text("Clear All Filters")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filter Users")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        Task {
                            await viewModel.searchUsers()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    DiscoverFiltersView(
        viewModel: DiscoverViewModel(
            socialRepository: SocialRepository()
        )
    )
}
