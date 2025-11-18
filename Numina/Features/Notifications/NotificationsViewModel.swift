//
//  NotificationsViewModel.swift
//  Numina
//
//  ViewModel for managing notifications
//

import Foundation
import SwiftData
import Combine

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var preferences: NotificationPreferences = .default
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let modelContext: ModelContext
    private let apiClient: APIClient

    init(modelContext: ModelContext, apiClient: APIClient = APIClient.shared) {
        self.modelContext = modelContext
        self.apiClient = apiClient
        loadLocalNotifications()
    }

    // MARK: - Load Notifications

    func loadLocalNotifications() {
        let descriptor = FetchDescriptor<AppNotification>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            notifications = try modelContext.fetch(descriptor)
        } catch {
            print("❌ Failed to load notifications: \(error.localizedDescription)")
            errorMessage = "Failed to load notifications"
        }
    }

    func fetchNotificationHistory() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: NotificationHistoryResponse = try await apiClient.request(
                endpoint: .getNotificationHistory,
                method: .get
            )

            // Save to local database
            for dto in response.notifications {
                // Check if notification already exists
                let descriptor = FetchDescriptor<AppNotification>(
                    predicate: #Predicate<AppNotification> { $0.id == dto.id }
                )

                let existing = try? modelContext.fetch(descriptor).first

                if existing == nil {
                    modelContext.insert(dto.toModel())
                }
            }

            try modelContext.save()
            loadLocalNotifications()
        } catch {
            print("❌ Failed to fetch notification history: \(error.localizedDescription)")
            errorMessage = "Failed to sync notifications"
        }

        isLoading = false
    }

    // MARK: - Mark as Read

    func markAsRead(_ notification: AppNotification) async {
        notification.isRead = true

        do {
            try modelContext.save()
            loadLocalNotifications()

            // Sync to backend
            let _: EmptyResponse = try await apiClient.request(
                endpoint: .markNotificationRead(id: notification.id),
                method: .post
            )
        } catch {
            print("❌ Failed to mark notification as read: \(error.localizedDescription)")
            notification.isRead = false
            try? modelContext.save()
        }
    }

    func markAllAsRead() async {
        for notification in notifications where !notification.isRead {
            notification.isRead = true
        }

        do {
            try modelContext.save()
            loadLocalNotifications()
        } catch {
            print("❌ Failed to mark all as read: \(error.localizedDescription)")
        }
    }

    // MARK: - Clear Notifications

    func clearAll() {
        for notification in notifications {
            modelContext.delete(notification)
        }

        do {
            try modelContext.save()
            loadLocalNotifications()
        } catch {
            print("❌ Failed to clear notifications: \(error.localizedDescription)")
            errorMessage = "Failed to clear notifications"
        }
    }

    func deleteNotification(_ notification: AppNotification) {
        modelContext.delete(notification)

        do {
            try modelContext.save()
            loadLocalNotifications()
        } catch {
            print("❌ Failed to delete notification: \(error.localizedDescription)")
        }
    }

    // MARK: - Preferences

    func loadPreferences() async {
        do {
            let response: NotificationPreferencesResponse = try await apiClient.request(
                endpoint: .getNotificationPreferences,
                method: .get
            )
            preferences = response.preferences
            savePreferencesToUserDefaults()
        } catch {
            print("❌ Failed to load preferences: \(error.localizedDescription)")
            loadPreferencesFromUserDefaults()
        }
    }

    func updatePreferences(_ newPreferences: NotificationPreferences) async {
        preferences = newPreferences
        savePreferencesToUserDefaults()

        do {
            let response = NotificationPreferencesResponse(preferences: newPreferences)
            let _: NotificationPreferencesResponse = try await apiClient.request(
                endpoint: .updateNotificationPreferences,
                method: .put,
                body: response
            )
        } catch {
            print("❌ Failed to update preferences: \(error.localizedDescription)")
            errorMessage = "Failed to save preferences"
        }
    }

    // MARK: - UserDefaults Persistence

    private func savePreferencesToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: "notificationPreferences")
        }
    }

    private func loadPreferencesFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "notificationPreferences"),
           let decoded = try? JSONDecoder().decode(NotificationPreferences.self, from: data) {
            preferences = decoded
        } else {
            preferences = .default
        }
    }

    // MARK: - Computed Properties

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var hasUnread: Bool {
        unreadCount > 0
    }

    func notifications(ofType type: NotificationType) -> [AppNotification] {
        notifications.filter { $0.notificationType == type }
    }
}
