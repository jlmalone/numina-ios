//
//  NotificationService.swift
//  Numina
//
//  Service for handling APNs push notifications
//

import Foundation
import UserNotifications
import SwiftData

@MainActor
class NotificationService: NSObject, ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var unreadCount: Int = 0

    private let modelContext: ModelContext
    private let apiClient: APIClient
    private var deviceToken: String?

    init(modelContext: ModelContext, apiClient: APIClient = APIClient.shared) {
        self.modelContext = modelContext
        self.apiClient = apiClient
        super.init()

        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }

    // MARK: - Permission Handling

    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])

        if granted {
            await registerForRemoteNotifications()
        }

        await checkAuthorizationStatus()
    }

    func checkAuthorizationStatus() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            authorizationStatus = settings.authorizationStatus
        }
    }

    @MainActor
    private func registerForRemoteNotifications() async {
        #if !targetEnvironment(simulator)
        await UIApplication.shared.registerForRemoteNotifications()
        #else
        print("⚠️ APNs not available in simulator")
        #endif
    }

    // MARK: - Device Token Management

    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = token

        Task {
            await registerDeviceToken(token)
        }
    }

    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }

    private func registerDeviceToken(_ token: String) async {
        do {
            let request = RegisterDeviceRequest(deviceToken: token, platform: "ios")
            let _: EmptyResponse = try await apiClient.request(
                endpoint: .registerDevice,
                method: .post,
                body: request
            )
            print("✅ Device token registered successfully")
        } catch {
            print("❌ Failed to register device token: \(error.localizedDescription)")
        }
    }

    // MARK: - Notification Handling

    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        guard let aps = userInfo["aps"] as? [String: Any] else { return }

        // Extract notification data
        let title = (aps["alert"] as? [String: Any])?["title"] as? String ?? ""
        let body = (aps["alert"] as? [String: Any])?["body"] as? String ?? ""
        let type = userInfo["type"] as? String ?? "reminder"
        let id = userInfo["id"] as? String ?? UUID().uuidString
        let relatedID = userInfo["relatedId"] as? String
        let imageURL = userInfo["imageUrl"] as? String

        // Create and save notification
        let notification = AppNotification(
            id: id,
            type: type,
            title: title,
            body: body,
            imageURL: imageURL,
            relatedID: relatedID,
            isRead: false
        )

        modelContext.insert(notification)

        do {
            try modelContext.save()
            updateUnreadCount()
            updateBadgeCount()
        } catch {
            print("❌ Failed to save notification: \(error.localizedDescription)")
        }
    }

    // MARK: - Badge Management

    func updateBadgeCount() {
        let descriptor = FetchDescriptor<AppNotification>(
            predicate: #Predicate { !$0.isRead }
        )

        do {
            let unreadNotifications = try modelContext.fetch(descriptor)
            let count = unreadNotifications.count

            Task { @MainActor in
                UIApplication.shared.applicationIconBadgeNumber = count
            }
        } catch {
            print("❌ Failed to update badge count: \(error.localizedDescription)")
        }
    }

    func updateUnreadCount() {
        let descriptor = FetchDescriptor<AppNotification>(
            predicate: #Predicate { !$0.isRead }
        )

        do {
            let unreadNotifications = try modelContext.fetch(descriptor)
            unreadCount = unreadNotifications.count
        } catch {
            print("❌ Failed to update unread count: \(error.localizedDescription)")
        }
    }

    // MARK: - Deep Linking

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo

        guard let type = userInfo["type"] as? String,
              let relatedID = userInfo["relatedId"] as? String else {
            return
        }

        // Post notification for deep linking
        NotificationCenter.default.post(
            name: .notificationTapped,
            object: nil,
            userInfo: ["type": type, "relatedId": relatedID]
        )
    }

    // MARK: - Settings

    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        Task { @MainActor in
            if UIApplication.shared.canOpenURL(settingsURL) {
                await UIApplication.shared.open(settingsURL)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        Task { @MainActor in
            handleNotification(notification.request.content.userInfo)
        }
        completionHandler([.banner, .sound, .badge])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        Task { @MainActor in
            handleNotificationResponse(response)
        }
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let notificationTapped = Notification.Name("notificationTapped")
}

// MARK: - Empty Response

struct EmptyResponse: Codable {}
