//
//  CreateActivityView.swift
//  Numina
//
//  Form for creating a group activity
//

import SwiftUI

struct CreateActivityView: View {
    let groupId: String
    @StateObject private var viewModel: CreateActivityViewModel
    @Environment(\.dismiss) var dismiss

    init(groupId: String) {
        self.groupId = groupId
        _viewModel = StateObject(wrappedValue: CreateActivityViewModel(groupId: groupId))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity Details") {
                    TextField("Title", text: $viewModel.title)

                    Picker("Type", selection: $viewModel.activityType) {
                        ForEach(CreateActivityViewModel.activityTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextEditor(text: $viewModel.description)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                }

                Section("Schedule") {
                    Toggle("Schedule Activity", isOn: $viewModel.hasScheduledTime)

                    if viewModel.hasScheduledTime {
                        DatePicker(
                            "Date & Time",
                            selection: $viewModel.scheduledTime,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

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

                Section("Capacity") {
                    Toggle("Limit Participants", isOn: $viewModel.hasMaxParticipants)

                    if viewModel.hasMaxParticipants {
                        Stepper("Max: \(viewModel.maxParticipants)", value: $viewModel.maxParticipants, in: 2...200)
                    }
                }

                Section("Link to Class") {
                    Toggle("Link Fitness Class", isOn: $viewModel.linkFitnessClass)

                    if viewModel.linkFitnessClass {
                        TextField("Class ID", text: $viewModel.fitnessClassId)
                            .autocapitalization(.none)
                    }
                }

                Section {
                    Button(action: {
                        Task {
                            await viewModel.createActivity()
                            if viewModel.createdSuccessfully {
                                dismiss()
                            }
                        }
                    }) {
                        if viewModel.isCreating {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Activity")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(viewModel.canCreate ? Color.blue : Color.gray)
                    .disabled(!viewModel.canCreate || viewModel.isCreating)
                }
            }
            .navigationTitle("New Activity")
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
}

@MainActor
final class CreateActivityViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var activityType = "workout"
    @Published var hasScheduledTime = true
    @Published var scheduledTime = Date().addingTimeInterval(86400) // Tomorrow
    @Published var hasLocation = false
    @Published var locationName = ""
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var hasMaxParticipants = false
    @Published var maxParticipants = 20
    @Published var linkFitnessClass = false
    @Published var fitnessClassId = ""

    @Published var isCreating = false
    @Published var createdSuccessfully = false
    @Published var errorMessage: String?

    static let activityTypes = [
        "workout", "fitness", "social", "event", "outdoor", "competition"
    ]

    let groupId: String
    private let groupRepository = GroupRepository()
    private let locationManager = LocationManager.shared

    init(groupId: String) {
        self.groupId = groupId
    }

    var canCreate: Bool {
        !title.isEmpty && !description.isEmpty &&
        (!hasLocation || !locationName.isEmpty)
    }

    func useCurrentLocation() {
        if let lat = locationManager.latitude, let lon = locationManager.longitude {
            latitude = lat
            longitude = lon
        }
    }

    func createActivity() async {
        isCreating = true
        errorMessage = nil

        let location: GroupLocationDTO? = hasLocation ? GroupLocationDTO(
            name: locationName,
            latitude: latitude,
            longitude: longitude
        ) : nil

        let request = CreateActivityRequest(
            title: title,
            description: description,
            type: activityType,
            scheduledTime: hasScheduledTime ? scheduledTime : nil,
            location: location,
            fitnessClassId: linkFitnessClass && !fitnessClassId.isEmpty ? fitnessClassId : nil,
            maxParticipants: hasMaxParticipants ? maxParticipants : nil
        )

        do {
            _ = try await groupRepository.createActivity(groupId: groupId, request: request)
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
    CreateActivityView(groupId: "group123")
}
