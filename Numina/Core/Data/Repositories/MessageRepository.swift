//
//  MessageRepository.swift
//  Numina
//
//  Repository for message data operations
//

import Foundation
import SwiftData

final class MessageRepository {
    private let apiClient: APIClient
    private let modelContext: ModelContext?

    init(apiClient: APIClient = .shared, modelContext: ModelContext? = nil) {
        self.apiClient = apiClient
        self.modelContext = modelContext
    }

    // MARK: - Conversations

    func getConversations(fromCache: Bool = false) async throws -> [Conversation] {
        if fromCache {
            return try getCachedConversations()
        }

        let response: ConversationListResponse = try await apiClient.request(
            endpoint: .getConversations
        )

        let conversations = response.conversations.map { $0.toModel() }

        // Cache conversations
        try await cacheConversations(conversations)

        return conversations
    }

    func getConversation(id: String, fromCache: Bool = false) async throws -> Conversation? {
        if fromCache, let cached = try getCachedConversation(id: id) {
            return cached
        }

        let conversationDTO: ConversationDTO = try await apiClient.request(
            endpoint: .getConversation(id: id)
        )

        let conversation = conversationDTO.toModel()

        // Cache conversation
        try await cacheConversation(conversation)

        return conversation
    }

    func createConversation(participantIds: [String]) async throws -> Conversation {
        let request = CreateConversationRequest(participantIds: participantIds)

        let conversationDTO: ConversationDTO = try await apiClient.request(
            endpoint: .createConversation,
            body: request
        )

        let conversation = conversationDTO.toModel()

        // Add to cache
        try await cacheConversation(conversation)

        return conversation
    }

    func deleteConversation(id: String) async throws {
        try await apiClient.requestWithoutResponse(
            endpoint: .deleteConversation(id: id)
        )

        // Remove from cache
        try await removeConversationFromCache(id: id)
    }

    // MARK: - Messages

    func getMessages(conversationId: String, fromCache: Bool = false) async throws -> [Message] {
        if fromCache {
            return try getCachedMessages(conversationId: conversationId)
        }

        let response: MessageListResponse = try await apiClient.request(
            endpoint: .getMessages(conversationId: conversationId)
        )

        let messages = response.messages.map { $0.toModel() }

        // Cache messages
        try await cacheMessages(messages, conversationId: conversationId)

        return messages
    }

    func sendMessage(conversationId: String, content: String, messageType: String = "text", imageURL: String? = nil) async throws -> Message {
        let request = SendMessageRequest(
            conversationId: conversationId,
            content: content,
            messageType: messageType,
            imageURL: imageURL
        )

        let messageDTO: MessageDTO = try await apiClient.request(
            endpoint: .sendMessage,
            body: request
        )

        let message = messageDTO.toModel()

        // Add to cache
        try await cacheMessage(message)

        return message
    }

    func markMessageAsRead(messageId: String) async throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate { $0.id == messageId }
        )

        let messages = try context.fetch(descriptor)
        for message in messages {
            message.isRead = true
        }

        try context.save()
    }

    // MARK: - User Search

    func searchUsers(query: String) async throws -> [User] {
        struct UserListResponse: Codable {
            let users: [UserDTO]
        }

        let response: UserListResponse = try await apiClient.request(
            endpoint: .searchUsers(query: query)
        )

        return response.users.map { $0.toModel() }
    }

    // MARK: - Local Cache - Conversations

    @MainActor
    private func cacheConversations(_ conversations: [Conversation]) throws {
        guard let context = modelContext else { return }

        // Insert or update conversations
        for conversation in conversations {
            let descriptor = FetchDescriptor<Conversation>(
                predicate: #Predicate { $0.id == conversation.id }
            )

            let existing = try context.fetch(descriptor)
            for existingConv in existing {
                context.delete(existingConv)
            }

            context.insert(conversation)
        }

        try context.save()
    }

    @MainActor
    private func cacheConversation(_ conversation: Conversation) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Conversation>(
            predicate: #Predicate { $0.id == conversation.id }
        )

        let existing = try context.fetch(descriptor)
        for existingConv in existing {
            context.delete(existingConv)
        }

        context.insert(conversation)
        try context.save()
    }

    private func getCachedConversations() throws -> [Conversation] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Conversation>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        return try context.fetch(descriptor)
    }

    private func getCachedConversation(id: String) throws -> Conversation? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<Conversation>(
            predicate: #Predicate { $0.id == id }
        )

        return try context.fetch(descriptor).first
    }

    @MainActor
    private func removeConversationFromCache(id: String) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Conversation>(
            predicate: #Predicate { $0.id == id }
        )

        let conversations = try context.fetch(descriptor)
        for conversation in conversations {
            context.delete(conversation)
        }

        try context.save()
    }

    // MARK: - Local Cache - Messages

    @MainActor
    private func cacheMessages(_ messages: [Message], conversationId: String) throws {
        guard let context = modelContext else { return }

        // Clear existing messages for this conversation
        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )

        let existing = try context.fetch(descriptor)
        for message in existing {
            context.delete(message)
        }

        // Insert new messages
        for message in messages {
            context.insert(message)
        }

        try context.save()
    }

    @MainActor
    private func cacheMessage(_ message: Message) throws {
        guard let context = modelContext else { return }

        // Check if message already exists
        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate { $0.id == message.id }
        )

        let existing = try context.fetch(descriptor)
        for existingMessage in existing {
            context.delete(existingMessage)
        }

        context.insert(message)
        try context.save()
    }

    private func getCachedMessages(conversationId: String) throws -> [Message] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate { $0.conversationId == conversationId },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        return try context.fetch(descriptor)
    }

    // MARK: - Update Conversation with New Message

    @MainActor
    func updateConversationWithNewMessage(_ message: Message) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Conversation>(
            predicate: #Predicate { $0.id == message.conversationId }
        )

        guard let conversation = try context.fetch(descriptor).first else { return }

        conversation.lastMessage = message.content
        conversation.lastMessageTime = message.timestamp
        conversation.lastMessageSenderId = message.senderId
        conversation.updatedAt = Date()

        try context.save()
    }

    // MARK: - Update Typing Indicator

    @MainActor
    func updateTypingIndicator(conversationId: String, isTyping: Bool, userName: String?) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Conversation>(
            predicate: #Predicate { $0.id == conversationId }
        )

        guard let conversation = try context.fetch(descriptor).first else { return }

        conversation.isTyping = isTyping
        conversation.typingUserName = userName

        try context.save()
    }

    // MARK: - Update Unread Count

    @MainActor
    func updateUnreadCount(conversationId: String, delta: Int) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Conversation>(
            predicate: #Predicate { $0.id == conversationId }
        )

        guard let conversation = try context.fetch(descriptor).first else { return }

        conversation.unreadCount = max(0, conversation.unreadCount + delta)

        try context.save()
    }

    @MainActor
    func resetUnreadCount(conversationId: String) throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Conversation>(
            predicate: #Predicate { $0.id == conversationId }
        )

        guard let conversation = try context.fetch(descriptor).first else { return }

        conversation.unreadCount = 0

        try context.save()
    }
}
