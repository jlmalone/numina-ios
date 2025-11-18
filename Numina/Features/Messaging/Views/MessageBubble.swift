//
//  MessageBubble.swift
//  Numina
//
//  Message bubble component for chat interface
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    let showAvatar: Bool
    let showTimestamp: Bool

    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            // Timestamp
            if showTimestamp {
                Text(message.formattedTimestamp)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, showAvatar ? 48 : 12)
                    .padding(.top, 8)
            }

            HStack(alignment: .bottom, spacing: 8) {
                // Avatar for other users
                if !isFromCurrentUser {
                    if showAvatar {
                        avatarView
                    } else {
                        Color.clear
                            .frame(width: 32, height: 32)
                    }
                }

                if isFromCurrentUser {
                    Spacer(minLength: 60)
                }

                // Message content
                VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                    // Sender name for group chats (if not current user)
                    if !isFromCurrentUser && showAvatar {
                        Text(message.senderName)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                            .padding(.leading, 12)
                    }

                    // Message bubble
                    messageBubbleContent
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(bubbleBackground)
                        .cornerRadius(16)
                }

                if !isFromCurrentUser {
                    Spacer(minLength: 60)
                }

                // Avatar placeholder for current user
                if isFromCurrentUser && showAvatar {
                    Color.clear
                        .frame(width: 32, height: 32)
                }
            }

            // Read receipt
            if isFromCurrentUser && message.isRead {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                    Text("Read")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
                .padding(.trailing, 12)
            }
        }
        .padding(.horizontal, 8)
    }

    private var avatarView: some View {
        Group {
            if let photoURL = message.senderPhotoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    defaultAvatar
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            } else {
                defaultAvatar
            }
        }
    }

    private var defaultAvatar: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.orange.opacity(0.7), .red.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 32, height: 32)
            .overlay(
                Text(message.senderName.prefix(1).uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
            )
    }

    private var messageBubbleContent: some View {
        Group {
            if message.messageType == "image", let imageURL = message.imageURL, let url = URL(string: imageURL) {
                VStack(alignment: .leading, spacing: 4) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                            .frame(width: 200, height: 200)
                    }
                    .frame(maxWidth: 200, maxHeight: 200)
                    .cornerRadius(8)

                    if !message.content.isEmpty {
                        Text(message.content)
                            .font(.body)
                            .foregroundColor(isFromCurrentUser ? .white : .primary)
                    }
                }
            } else {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .textSelection(.enabled)
            }
        }
    }

    private var bubbleBackground: some View {
        Group {
            if isFromCurrentUser {
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color(.systemGray5)
            }
        }
    }
}

// MARK: - Preview

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Sent message
            MessageBubble(
                message: Message(
                    id: "1",
                    conversationId: "conv1",
                    senderId: "user1",
                    senderName: "Me",
                    content: "Hey! How are you?",
                    timestamp: Date(),
                    isRead: true
                ),
                isFromCurrentUser: true,
                showAvatar: true,
                showTimestamp: true
            )

            // Received message
            MessageBubble(
                message: Message(
                    id: "2",
                    conversationId: "conv1",
                    senderId: "user2",
                    senderName: "Sarah",
                    content: "I'm doing great! Just finished an amazing HIIT class.",
                    timestamp: Date().addingTimeInterval(-300)
                ),
                isFromCurrentUser: false,
                showAvatar: true,
                showTimestamp: true
            )
        }
        .padding()
    }
}
