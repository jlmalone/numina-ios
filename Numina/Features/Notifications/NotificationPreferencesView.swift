//
//  NotificationPreferencesView.swift
//  Numina
//
//  Notification preferences and settings view
//

import SwiftUI

struct NotificationPreferencesView: View {
    @ObservedObject var viewModel: NotificationsViewModel
    @ObservedObject var notificationService: NotificationService
    @Environment(\.dismiss) var dismiss

    @State private var preferences: NotificationPreferences
    @State private var isSaving = false

    init(viewModel: NotificationsViewModel, notificationService: NotificationService) {
        self.viewModel = viewModel
        self.notificationService = notificationService
        _preferences = State(initialValue: viewModel.preferences)
    }

    var body: some View {
        List {
            // System Permission Section
            Section {
                HStack {
                    Label("Notification Permission", systemImage: "bell.badge")
                        .foregroundColor(.primary)

                    Spacer()

                    statusBadge
                }

                if notificationService.authorizationStatus != .authorized {
                    Button(action: handlePermissionAction) {
                        Text(permissionActionText)
                            .foregroundColor(.orange)
                    }
                }
            } header: {
                Text("System Settings")
            } footer: {
                Text("Notifications must be enabled in system settings to receive updates.")
            }

            // Notification Types
            Section {
                Toggle(isOn: $preferences.messagesEnabled) {
                    Label("Messages", systemImage: "message.fill")
                }
                .tint(.orange)

                Toggle(isOn: $preferences.matchesEnabled) {
                    Label("Matches", systemImage: "person.2.fill")
                }
                .tint(.orange)

                Toggle(isOn: $preferences.groupsEnabled) {
                    Label("Groups", systemImage: "person.3.fill")
                }
                .tint(.orange)

                Toggle(isOn: $preferences.remindersEnabled) {
                    Label("Reminders", systemImage: "bell.fill")
                }
                .tint(.orange)
            } header: {
                Text("Notification Types")
            } footer: {
                Text("Choose which types of notifications you want to receive.")
            }

            // Quiet Hours
            Section {
                Toggle(isOn: $preferences.quietHoursEnabled) {
                    Label("Quiet Hours", systemImage: "moon.fill")
                }
                .tint(.orange)

                if preferences.quietHoursEnabled {
                    HStack {
                        Text("Start Time")
                        Spacer()
                        Text(preferences.quietHoursStart)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("End Time")
                        Spacer()
                        Text(preferences.quietHoursEnd)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Quiet Hours")
            } footer: {
                Text("Mute notifications during specified hours.")
            }

            // Email Fallback
            Section {
                Toggle(isOn: $preferences.emailFallbackEnabled) {
                    Label("Email Fallback", systemImage: "envelope.fill")
                }
                .tint(.orange)
            } header: {
                Text("Email Notifications")
            } footer: {
                Text("Receive important notifications via email when push notifications are disabled.")
            }

            // Save Button
            Section {
                Button(action: savePreferences) {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save Preferences")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(isSaving || !hasChanges)
                .foregroundColor(hasChanges ? .orange : .secondary)
            }
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadPreferences()
                preferences = viewModel.preferences
            }
        }
    }

    private var statusBadge: some View {
        Group {
            switch notificationService.authorizationStatus {
            case .authorized:
                Text("Enabled")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            case .denied:
                Text("Disabled")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(8)
            case .notDetermined:
                Text("Not Set")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            default:
                Text("Unknown")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.gray)
                    .cornerRadius(8)
            }
        }
    }

    private var permissionActionText: String {
        switch notificationService.authorizationStatus {
        case .notDetermined:
            return "Enable Notifications"
        case .denied:
            return "Open Settings"
        default:
            return ""
        }
    }

    private var hasChanges: Bool {
        preferences.messagesEnabled != viewModel.preferences.messagesEnabled ||
        preferences.matchesEnabled != viewModel.preferences.matchesEnabled ||
        preferences.groupsEnabled != viewModel.preferences.groupsEnabled ||
        preferences.remindersEnabled != viewModel.preferences.remindersEnabled ||
        preferences.quietHoursEnabled != viewModel.preferences.quietHoursEnabled ||
        preferences.quietHoursStart != viewModel.preferences.quietHoursStart ||
        preferences.quietHoursEnd != viewModel.preferences.quietHoursEnd ||
        preferences.emailFallbackEnabled != viewModel.preferences.emailFallbackEnabled
    }

    private func handlePermissionAction() {
        switch notificationService.authorizationStatus {
        case .notDetermined:
            Task {
                try? await notificationService.requestAuthorization()
            }
        case .denied:
            notificationService.openSettings()
        default:
            break
        }
    }

    private func savePreferences() {
        Task {
            isSaving = true
            await viewModel.updatePreferences(preferences)
            isSaving = false

            // Dismiss after short delay
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            dismiss()
        }
    }
}

#Preview {
    NavigationView {
        NotificationPreferencesView(
            viewModel: NotificationsViewModel(modelContext: ModelContext(try! ModelContainer(for: AppNotification.self))),
            notificationService: NotificationService(modelContext: ModelContext(try! ModelContainer(for: AppNotification.self)))
        )
    }
}
