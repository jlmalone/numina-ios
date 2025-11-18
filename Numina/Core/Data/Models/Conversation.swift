//
//  Conversation.swift
//  Numina
//
//  Conversation data model
//

import Foundation
import SwiftData

@Model
final class Conversation {
    @Attribute(.unique) var id: String
    var participantIds: [String]
    var participantNames: [String]
    var participantPhotoURLs: [String]
    var lastMessage: String?
    var lastMessageTime: Date?
    var lastMessageSenderId: String?
    var unreadCount: Int
    var isTyping: Bool
    var typingUserName: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        participantIds: [String],
        participantNames: [String],
        participantPhotoURLs: [String] = [],
        lastMessage: String? = nil,
        lastMessageTime: Date? = nil,
        lastMessageSenderId: String? = nil,
        unreadCount: Int = 0,
        isTyping: Bool = false,
        typingUserName: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.participantIds = participantIds
        self.participantNames = participantNames
        self.participantPhotoURLs = participantPhotoURLs
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.lastMessageSenderId = lastMessageSenderId
        self.unreadCount = unreadCount
        self.isTyping = isTyping
        self.typingUserName = typingUserName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Codable Conversation DTO

struct ConversationDTO: Codable {
    let id: String
    let participants: [ConversationParticipantDTO]
    let lastMessage: String?
    let lastMessageTime: Date?
    let lastMessageSenderId: String?
    let unreadCount: Int
    let createdAt: Date
    let updatedAt: Date

    func toModel() -> Conversation {
        Conversation(
            id: id,
            participantIds: participants.map { $0.id },
            participantNames: participants.map { $0.name },
            participantPhotoURLs: participants.compactMap { $0.photoURL },
            lastMessage: lastMessage,
            lastMessageTime: lastMessageTime,
            lastMessageSenderId: lastMessageSenderId,
            unreadCount: unreadCount,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Conversation {
    func toDTO() -> ConversationDTO {
        let participants = zip(participantIds, participantNames).enumerated().map { index, pair in
            ConversationParticipantDTO(
                id: pair.0,
                name: pair.1,
                photoURL: index < participantPhotoURLs.count ? participantPhotoURLs[index] : nil
            )
        }

        return ConversationDTO(
            id: id,
            participants: participants,
            lastMessage: lastMessage,
            lastMessageTime: lastMessageTime,
            lastMessageSenderId: lastMessageSenderId,
            unreadCount: unreadCount,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var displayName: String {
        participantNames.joined(separator: ", ")
    }

    var displayPhotoURL: String? {
        participantPhotoURLs.first
    }

    var formattedLastMessageTime: String {
        guard let time = lastMessageTime else { return "" }

        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(time) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: time)
        } else if calendar.isDateInYesterday(time) {
            return "Yesterday"
        } else if calendar.component(.weekOfYear, from: time) == calendar.component(.weekOfYear, from: Date()) {
            formatter.dateFormat = "EEEE" // Day name
            return formatter.string(from: time)
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: time)
        }
    }
}

// MARK: - Supporting Models

struct ConversationParticipantDTO: Codable {
    let id: String
    let name: String
    let photoURL: String?
}

// MARK: - Conversation List Response

struct ConversationListResponse: Codable {
    let conversations: [ConversationDTO]
    let total: Int
    let page: Int?
    let limit: Int?
}

// MARK: - Create Conversation Request

struct CreateConversationRequest: Codable {
    let participantIds: [String]
}

// MARK: - WebSocket Message Events

struct WebSocketMessageEvent: Codable {
    let type: String // "new_message", "typing_start", "typing_stop", "read_receipt"
    let data: WebSocketEventData
}

struct WebSocketEventData: Codable {
    let conversationId: String?
    let message: MessageDTO?
    let userId: String?
    let userName: String?
}
