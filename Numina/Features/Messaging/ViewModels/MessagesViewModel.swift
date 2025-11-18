//
//  MessagesViewModel.swift
//  Numina
//
//  ViewModel for conversations list
//

import Foundation
import SwiftData
import Combine

@MainActor
final class MessagesViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""

    private let messageRepository: MessageRepository
    private let webSocketService: WebSocketService
    private var cancellables = Set<AnyCancellable>()

    init(messageRepository: MessageRepository, webSocketService: WebSocketService = .shared) {
        self.messageRepository = messageRepository
        self.webSocketService = webSocketService
        setupWebSocketSubscriptions()
    }

    // MARK: - Load Conversations

    func loadConversations(fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            conversations = try await messageRepository.getConversations(fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshConversations() async {
        await loadConversations(fromCache: false)
    }

    // MARK: - Create Conversation

    func createConversation(with participantIds: [String]) async throws -> Conversation {
        return try await messageRepository.createConversation(participantIds: participantIds)
    }

    // MARK: - Delete Conversation

    func deleteConversation(id: String) async {
        do {
            try await messageRepository.deleteConversation(id: id)
            conversations.removeAll { $0.id == id }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func archiveConversation(id: String) {
        // Archive locally (server implementation would handle persistence)
        conversations.removeAll { $0.id == id }
    }

    // MARK: - WebSocket Integration

    private func setupWebSocketSubscriptions() {
        // Listen for new messages
        webSocketService.messageReceived
            .sink { [weak self] message in
                guard let self = self else { return }
                Task { @MainActor in
                    try? self.messageRepository.updateConversationWithNewMessage(message)
                    await self.loadConversations(fromCache: true)
                }
            }
            .store(in: &cancellables)

        // Listen for typing indicators
        webSocketService.typingEvent
            .sink { [weak self] event in
                guard let self = self else { return }
                Task { @MainActor in
                    try? self.messageRepository.updateTypingIndicator(
                        conversationId: event.conversationId,
                        isTyping: event.isTyping,
                        userName: event.userName
                    )
                    await self.loadConversations(fromCache: true)
                }
            }
            .store(in: &cancellables)

        // Listen for connection state
        webSocketService.connectionStateChanged
            .sink { [weak self] isConnected in
                if isConnected {
                    Task { @MainActor [weak self] in
                        await self?.refreshConversations()
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Connect to WebSocket

    func connectWebSocket() async {
        do {
            try await webSocketService.connect()
        } catch {
            errorMessage = "Failed to connect to real-time messaging"
        }
    }

    func disconnectWebSocket() {
        webSocketService.disconnect()
    }

    // MARK: - Filtering

    var filteredConversations: [Conversation] {
        if searchQuery.isEmpty {
            return conversations
        }

        return conversations.filter { conversation in
            conversation.displayName.localizedCaseInsensitiveContains(searchQuery) ||
            (conversation.lastMessage?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }

    // MARK: - Unread Count

    var totalUnreadCount: Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }
}
