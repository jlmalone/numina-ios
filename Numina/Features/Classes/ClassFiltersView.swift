//
//  ClassFiltersView.swift
//  Numina
//
//  Filters sheet for class discovery
//

import SwiftUI

struct ClassFiltersView: View {
    @ObservedObject var viewModel: ClassViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Date Range
                Section("Date Range") {
                    DatePicker(
                        "Start Date",
                        selection: Binding(
                            get: { viewModel.startDate ?? Date() },
                            set: { viewModel.startDate = $0 }
                        ),
                        displayedComponents: [.date]
                    )

                    DatePicker(
                        "End Date",
                        selection: Binding(
                            get: { viewModel.endDate ?? Date().addingTimeInterval(7 * 24 * 60 * 60) },
                            set: { viewModel.endDate = $0 }
                        ),
                        displayedComponents: [.date]
                    )

                    Button("Clear Dates") {
                        viewModel.startDate = nil
                        viewModel.endDate = nil
                    }
                    .foregroundColor(.orange)
                }

                // Class Type
                Section("Class Type") {
                    Picker("Type", selection: $viewModel.selectedClassType) {
                        ForEach(viewModel.classTypes, id: \.self) { type in
                            Text(type).tag(type as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Location
                Section("Location") {
                    Toggle("Use Current Location", isOn: $viewModel.useCurrentLocation)

                    if viewModel.useCurrentLocation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Radius: \(Int(viewModel.locationRadius)) miles")
                                .font(.subheadline)

                            Slider(value: $viewModel.locationRadius, in: 1...50, step: 1)
                                .tint(.orange)
                        }
                    }
                }

                // Price Range
                Section("Price Range") {
                    HStack {
                        Text("Min:")
                        TextField("$0", value: $viewModel.minPrice, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack {
                        Text("Max:")
                        TextField("$100", value: $viewModel.maxPrice, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    Button("Clear Price Range") {
                        viewModel.minPrice = nil
                        viewModel.maxPrice = nil
                    }
                    .foregroundColor(.orange)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.red)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        Task {
                            await viewModel.loadClasses()
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

#Preview {
    ClassFiltersView(viewModel: ClassViewModel(classRepository: ClassRepository()))
}
