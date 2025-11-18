//
//  ReminderPreferencesView.swift
//  Numina
//
//  Reminder settings view
//

import SwiftUI

struct ReminderPreferencesView: View {
    @StateObject private var viewModel: ReminderPreferencesViewModel
    @Environment(\.dismiss) private var dismiss

    init(bookingRepository: BookingRepository) {
        _viewModel = StateObject(wrappedValue: ReminderPreferencesViewModel(bookingRepository: bookingRepository))
    }

    var body: some View {
        Form {
            Section(header: Text("Default Settings")) {
                Toggle("Enable Reminders by Default", isOn: $viewModel.defaultEnabled)

                if viewModel.defaultEnabled {
                    Picker("Default Reminder Time", selection: $viewModel.defaultReminderTime) {
                        Text("15 minutes").tag(15)
                        Text("30 minutes").tag(30)
                        Text("1 hour").tag(60)
                        Text("2 hours").tag(120)
                        Text("1 day").tag(1440)
                    }
                }
            }

            Section(header: Text("Notification Types")) {
                Toggle("1 Hour Before", isOn: $viewModel.oneHourEnabled)
                Toggle("24 Hours Before", isOn: $viewModel.twentyFourHourEnabled)
            }

            Section(header: Text("Quiet Hours")) {
                Toggle("Enable Quiet Hours", isOn: $viewModel.quietHoursEnabled)

                if viewModel.quietHoursEnabled {
                    DatePicker("Start", selection: $viewModel.quietHoursStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $viewModel.quietHoursEnd, displayedComponents: .hourAndMinute)

                    Text("No reminders will be sent during quiet hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                Button("Save Preferences") {
                    Task {
                        let success = await viewModel.savePreferences()
                        if success {
                            dismiss()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Reminder Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.loadPreferences()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

@MainActor
final class ReminderPreferencesViewModel: ObservableObject {
    @Published var defaultEnabled = true
    @Published var defaultReminderTime = 60
    @Published var oneHourEnabled = true
    @Published var twentyFourHourEnabled = false
    @Published var quietHoursEnabled = false
    @Published var quietHoursStart = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @Published var quietHoursEnd = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let bookingRepository: BookingRepository
    private var preferences: ReminderPreferences?

    init(bookingRepository: BookingRepository) {
        self.bookingRepository = bookingRepository
    }

    func loadPreferences() async {
        isLoading = true
        errorMessage = nil

        do {
            preferences = try await bookingRepository.getReminderPreferences(fromCache: true)

            if let prefs = preferences {
                defaultEnabled = prefs.defaultEnabled
                defaultReminderTime = prefs.defaultReminderTime
                oneHourEnabled = prefs.oneHourEnabled
                twentyFourHourEnabled = prefs.twentyFourHourEnabled
                quietHoursEnabled = prefs.quietHoursEnabled

                if let start = prefs.quietHoursStart {
                    quietHoursStart = start
                }

                if let end = prefs.quietHoursEnd {
                    quietHoursEnd = end
                }
            }
        } catch {
            // Use defaults if loading fails
            print("Failed to load preferences: \(error)")
        }

        isLoading = false
    }

    func savePreferences() async -> Bool {
        isLoading = true
        errorMessage = nil

        // Create or update preferences
        let prefs = ReminderPreferences(
            userId: preferences?.userId ?? "current",
            defaultEnabled: defaultEnabled,
            defaultReminderTime: defaultReminderTime,
            oneHourEnabled: oneHourEnabled,
            twentyFourHourEnabled: twentyFourHourEnabled,
            quietHoursEnabled: quietHoursEnabled,
            quietHoursStart: quietHoursEnabled ? quietHoursStart : nil,
            quietHoursEnd: quietHoursEnabled ? quietHoursEnd : nil
        )

        do {
            preferences = try await bookingRepository.updateReminderPreferences(prefs)
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        return false
    }
}

#Preview {
    NavigationStack {
        ReminderPreferencesView(bookingRepository: BookingRepository())
    }
}
