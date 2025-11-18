//
//  Message.swift
//  Numina
//
//  Message data model
//

import Foundation
import SwiftData

@Model
final class Message {
    @Attribute(.unique) var id: String
    var conversationId: String
    var senderId: String
    var senderName: String
    var senderPhotoURL: String?
    var content: String
    var timestamp: Date
    var isRead: Bool
    var messageType: String // "text", "image", "system"
    var imageURL: String?
    var createdAt: Date

    init(
        id: String,
        conversationId: String,
        senderId: String,
        senderName: String,
        senderPhotoURL: String? = nil,
        content: String,
        timestamp: Date = Date(),
        isRead: Bool = false,
        messageType: String = "text",
        imageURL: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.senderName = senderName
        self.senderPhotoURL = senderPhotoURL
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
        self.messageType = messageType
        self.imageURL = imageURL
        self.createdAt = createdAt
    }
}

// MARK: - Codable Message DTO

struct MessageDTO: Codable {
    let id: String
    let conversationId: String
    let senderId: String
    let senderName: String
    let senderPhotoURL: String?
    let content: String
    let timestamp: Date
    let isRead: Bool
    let messageType: String
    let imageURL: String?
    let createdAt: Date

    func toModel() -> Message {
        Message(
            id: id,
            conversationId: conversationId,
            senderId: senderId,
            senderName: senderName,
            senderPhotoURL: senderPhotoURL,
            content: content,
            timestamp: timestamp,
            isRead: isRead,
            messageType: messageType,
            imageURL: imageURL,
            createdAt: createdAt
        )
    }
}

extension Message {
    func toDTO() -> MessageDTO {
        MessageDTO(
            id: id,
            conversationId: conversationId,
            senderId: senderId,
            senderName: senderName,
            senderPhotoURL: senderPhotoURL,
            content: content,
            timestamp: timestamp,
            isRead: isRead,
            messageType: messageType,
            imageURL: imageURL,
            createdAt: createdAt
        )
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(timestamp) {
            return "Today"
        } else if calendar.isDateInYesterday(timestamp) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: timestamp)
        }
    }
}

// MARK: - Send Message Request

struct SendMessageRequest: Codable {
    let conversationId: String
    let content: String
    let messageType: String
    let imageURL: String?
}

// MARK: - Message List Response

struct MessageListResponse: Codable {
    let messages: [MessageDTO]
    let total: Int
    let page: Int?
    let limit: Int?
}
