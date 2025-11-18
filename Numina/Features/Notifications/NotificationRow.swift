//
//  NotificationRow.swift
//  Numina
//
//  Row component for displaying a notification
//

import SwiftUI

struct NotificationRow: View {
    let notification: AppNotification
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 44, height: 44)

                    Image(systemName: notification.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)

                        Spacer()

                        if !notification.isRead {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                        }
                    }

                    Text(notification.body)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Text(timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(notification.isRead ? Color.clear : Color.orange.opacity(0.05))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var iconBackgroundColor: Color {
        switch notification.notificationType {
        case .message:
            return .blue
        case .match:
            return .orange
        case .group:
            return .purple
        case .reminder:
            return .green
        }
    }

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: notification.createdAt, relativeTo: Date())
    }
}

#Preview {
    VStack(spacing: 0) {
        NotificationRow(
            notification: AppNotification(
                type: "message",
                title: "New Message",
                body: "Sarah sent you a message about tomorrow's yoga class",
                isRead: false
            ),
            onTap: {}
        )

        Divider()

        NotificationRow(
            notification: AppNotification(
                type: "match",
                title: "New Match!",
                body: "You matched with Alex for spinning class",
                isRead: true
            ),
            onTap: {}
        )

        Divider()

        NotificationRow(
            notification: AppNotification(
                type: "group",
                title: "Group Invite",
                body: "You've been invited to join 'Morning Runners'",
                isRead: false
            ),
            onTap: {}
        )
    }
}
