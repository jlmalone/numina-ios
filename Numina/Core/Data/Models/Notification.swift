//
//  Notification.swift
//  Numina
//
//  Notification data model
//

import Foundation
import SwiftData

@Model
final class AppNotification {
    @Attribute(.unique) var id: String
    var type: String // "message", "match", "group", "reminder"
    var title: String
    var body: String
    var imageURL: String?
    var relatedID: String? // ID of related entity (user, class, group, etc.)
    var isRead: Bool
    var createdAt: Date
    var data: [String: String]? // Additional metadata

    init(
        id: String = UUID().uuidString,
        type: String,
        title: String,
        body: String,
        imageURL: String? = nil,
        relatedID: String? = nil,
        isRead: Bool = false,
        createdAt: Date = Date(),
        data: [String: String]? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.imageURL = imageURL
        self.relatedID = relatedID
        self.isRead = isRead
        self.createdAt = createdAt
        self.data = data
    }

    var notificationType: NotificationType {
        NotificationType(rawValue: type) ?? .reminder
    }

    var icon: String {
        switch notificationType {
        case .message:
            return "message.fill"
        case .match:
            return "person.2.fill"
        case .group:
            return "person.3.fill"
        case .reminder:
            return "bell.fill"
        }
    }
}

enum NotificationType: String, Codable, CaseIterable {
    case message = "message"
    case match = "match"
    case group = "group"
    case reminder = "reminder"

    var displayName: String {
        switch self {
        case .message: return "Messages"
        case .match: return "Matches"
        case .group: return "Groups"
        case .reminder: return "Reminders"
        }
    }
}

// MARK: - Notification DTOs

struct NotificationDTO: Codable {
    let id: String
    let type: String
    let title: String
    let body: String
    let imageURL: String?
    let relatedID: String?
    let isRead: Bool
    let createdAt: Date
    let data: [String: String]?

    func toModel() -> AppNotification {
        AppNotification(
            id: id,
            type: type,
            title: title,
            body: body,
            imageURL: imageURL,
            relatedID: relatedID,
            isRead: isRead,
            createdAt: createdAt,
            data: data
        )
    }
}

extension AppNotification {
    func toDTO() -> NotificationDTO {
        NotificationDTO(
            id: id,
            type: type,
            title: title,
            body: body,
            imageURL: imageURL,
            relatedID: relatedID,
            isRead: isRead,
            createdAt: createdAt,
            data: data
        )
    }
}

// MARK: - Notification Preferences

struct NotificationPreferences: Codable {
    var messagesEnabled: Bool
    var matchesEnabled: Bool
    var groupsEnabled: Bool
    var remindersEnabled: Bool
    var quietHoursEnabled: Bool
    var quietHoursStart: String // HH:mm format
    var quietHoursEnd: String // HH:mm format
    var emailFallbackEnabled: Bool

    static let `default` = NotificationPreferences(
        messagesEnabled: true,
        matchesEnabled: true,
        groupsEnabled: true,
        remindersEnabled: true,
        quietHoursEnabled: false,
        quietHoursStart: "22:00",
        quietHoursEnd: "08:00",
        emailFallbackEnabled: true
    )

    func isEnabled(for type: NotificationType) -> Bool {
        switch type {
        case .message: return messagesEnabled
        case .match: return matchesEnabled
        case .group: return groupsEnabled
        case .reminder: return remindersEnabled
        }
    }
}

// MARK: - Device Token Registration

struct RegisterDeviceRequest: Codable {
    let deviceToken: String
    let platform: String // "ios"
}

struct NotificationHistoryResponse: Codable {
    let notifications: [NotificationDTO]
}

struct NotificationPreferencesResponse: Codable {
    let preferences: NotificationPreferences
}
