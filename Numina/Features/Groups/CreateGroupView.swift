//
//  CreateGroupView.swift
//  Numina
//
//  Multi-step form for creating a group
//

import SwiftUI

struct CreateGroupView: View {
    @StateObject private var viewModel = CreateGroupViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 0

    var body: some View {
        NavigationStack {
            VStack {
                // Progress Indicator
                ProgressView(value: Double(currentStep + 1), total: 3)
                    .padding()

                Text("Step \(currentStep + 1) of 3")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Step Content
                TabView(selection: $currentStep) {
                    basicInfoStep.tag(0)
                    detailsStep.tag(1)
                    locationStep.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation Buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }

                    Button(currentStep == 2 ? "Create Group" : "Next") {
                        if currentStep == 2 {
                            Task {
                                await viewModel.createGroup()
                                if viewModel.createdSuccessfully {
                                    dismiss()
                                }
                            }
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canProceed(from: currentStep) ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!viewModel.canProceed(from: currentStep) || viewModel.isCreating)
                }
                .padding()
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    private var basicInfoStep: some View {
        Form {
            Section("Group Name") {
                TextField("Enter group name", text: $viewModel.name)
            }

            Section("Category") {
                Picker("Category", selection: $viewModel.category) {
                    ForEach(CreateGroupViewModel.categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Privacy") {
                Picker("Privacy", selection: $viewModel.privacy) {
                    Text("Public").tag("public")
                    Text("Private").tag("private")
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var detailsStep: some View {
        Form {
            Section("Description") {
                TextEditor(text: $viewModel.description)
                    .frame(height: 150)
            }

            Section("Image URL (Optional)") {
                TextField("https://example.com/image.jpg", text: $viewModel.imageURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }

            Section("Group Size") {
                Toggle("Set Maximum Members", isOn: $viewModel.hasMaxMembers)

                if viewModel.hasMaxMembers {
                    Stepper("Max: \(viewModel.maxMembers)", value: $viewModel.maxMembers, in: 2...500)
                }
            }
        }
    }

    private var locationStep: some View {
        Form {
            Section("Location") {
                Toggle("Add Location", isOn: $viewModel.hasLocation)

                if viewModel.hasLocation {
                    TextField("Location Name", text: $viewModel.locationName)

                    HStack {
                        TextField("Latitude", value: $viewModel.latitude, format: .number)
                            .keyboardType(.decimalPad)

                        TextField("Longitude", value: $viewModel.longitude, format: .number)
                            .keyboardType(.decimalPad)
                    }

                    Button("Use Current Location") {
                        viewModel.useCurrentLocation()
                    }
                    .foregroundColor(.blue)
                }
            }

            Section {
                Text("Review your group settings and tap 'Create Group' to finish.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

@MainActor
final class CreateGroupViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var category = "Fitness"
    @Published var privacy = "public"
    @Published var imageURL = ""
    @Published var hasMaxMembers = false
    @Published var maxMembers = 50
    @Published var hasLocation = false
    @Published var locationName = ""
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0

    @Published var isCreating = false
    @Published var createdSuccessfully = false
    @Published var errorMessage: String?

    static let categories = [
        "Fitness", "Yoga", "Running", "Cycling", "Swimming",
        "CrossFit", "HIIT", "Strength Training", "Sports",
        "Wellness", "Social", "Outdoor", "Dance"
    ]

    private let groupRepository = GroupRepository()
    private let locationManager = LocationManager.shared

    func canProceed(from step: Int) -> Bool {
        switch step {
        case 0:
            return !name.isEmpty && !category.isEmpty
        case 1:
            return !description.isEmpty
        case 2:
            if hasLocation {
                return !locationName.isEmpty
            }
            return true
        default:
            return false
        }
    }

    func useCurrentLocation() {
        if let lat = locationManager.latitude, let lon = locationManager.longitude {
            latitude = lat
            longitude = lon
        }
    }

    func createGroup() async {
        isCreating = true
        errorMessage = nil

        let location: GroupLocationDTO? = hasLocation ? GroupLocationDTO(
            name: locationName,
            latitude: latitude,
            longitude: longitude
        ) : nil

        let request = CreateGroupRequest(
            name: name,
            description: description,
            category: category,
            privacy: privacy,
            imageURL: imageURL.isEmpty ? nil : imageURL,
            maxMembers: hasMaxMembers ? maxMembers : nil,
            location: location
        )

        do {
            _ = try await groupRepository.createGroup(request: request)
            createdSuccessfully = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isCreating = false
    }
}

#Preview {
    CreateGroupView()
}
