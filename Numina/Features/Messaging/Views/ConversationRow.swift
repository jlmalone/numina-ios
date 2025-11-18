//
//  ConversationRow.swift
//  Numina
//
//  Conversation list item component
//

import SwiftUI

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            avatarView
                .frame(width: 56, height: 56)

            // Conversation info
            VStack(alignment: .leading, spacing: 4) {
                // Name and time
                HStack {
                    Text(conversation.displayName)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    if let time = conversation.lastMessageTime {
                        Text(conversation.formattedLastMessageTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Last message
                HStack(spacing: 4) {
                    if conversation.isTyping, let typingUser = conversation.typingUserName {
                        HStack(spacing: 4) {
                            TypingIndicator()
                            Text("\(typingUser) is typing...")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .italic()
                        }
                    } else if let lastMessage = conversation.lastMessage {
                        Text(lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    } else {
                        Text("No messages yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }

                    Spacer()

                    // Unread badge
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .padding(.horizontal, 6)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var avatarView: some View {
        Group {
            if let photoURL = conversation.displayPhotoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    defaultAvatar
                }
                .frame(width: 56, height: 56)
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
            .frame(width: 56, height: 56)
            .overlay(
                Text(conversation.displayName.prefix(1).uppercased())
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
            )
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.orange)
                    .frame(width: 6, height: 6)
                    .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationPhase
                    )
            }
        }
        .onAppear {
            // Trigger animation
            withAnimation {
                animationPhase = 1
            }
        }
    }
}

// MARK: - Preview

struct ConversationRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ConversationRow(
                conversation: Conversation(
                    id: "1",
                    participantIds: ["user1", "user2"],
                    participantNames: ["Sarah Johnson"],
                    lastMessage: "See you at the gym tomorrow!",
                    lastMessageTime: Date().addingTimeInterval(-3600),
                    unreadCount: 2
                )
            )
            .padding(.horizontal)

            Divider()

            ConversationRow(
                conversation: Conversation(
                    id: "2",
                    participantIds: ["user1", "user3"],
                    participantNames: ["Mike Chen"],
                    lastMessage: "That HIIT class was amazing! 🔥",
                    lastMessageTime: Date().addingTimeInterval(-86400),
                    unreadCount: 0,
                    isTyping: true,
                    typingUserName: "Mike"
                )
            )
            .padding(.horizontal)

            Divider()

            ConversationRow(
                conversation: Conversation(
                    id: "3",
                    participantIds: ["user1", "user4"],
                    participantNames: ["Emily Rodriguez"],
                    lastMessage: nil,
                    lastMessageTime: nil,
                    unreadCount: 0
                )
            )
            .padding(.horizontal)
        }
    }
}
