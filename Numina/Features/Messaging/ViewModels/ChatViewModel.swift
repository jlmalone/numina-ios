//
//  ChatViewModel.swift
//  Numina
//
//  ViewModel for individual chat with WebSocket integration
//

import Foundation
import SwiftData
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var conversation: Conversation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var messageText = ""
    @Published var isTyping = false
    @Published var otherUserTyping = false
    @Published var otherUserTypingName: String?
    @Published var isSending = false

    private let conversationId: String
    private let currentUserId: String
    private let messageRepository: MessageRepository
    private let webSocketService: WebSocketService
    private var cancellables = Set<AnyCancellable>()
    private var typingDebounceTask: Task<Void, Never>?

    init(
        conversationId: String,
        currentUserId: String,
        messageRepository: MessageRepository,
        webSocketService: WebSocketService = .shared
    ) {
        self.conversationId = conversationId
        self.currentUserId = currentUserId
        self.messageRepository = messageRepository
        self.webSocketService = webSocketService
        setupWebSocketSubscriptions()
    }

    // MARK: - Load Messages

    func loadMessages(fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            messages = try await messageRepository.getMessages(conversationId: conversationId, fromCache: fromCache)
            conversation = try await messageRepository.getConversation(id: conversationId, fromCache: fromCache)

            // Mark messages as read
            await markMessagesAsRead()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshMessages() async {
        await loadMessages(fromCache: false)
    }

    // MARK: - Send Message

    func sendMessage() async {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let text = messageText
        messageText = "" // Clear immediately for better UX
        isSending = true

        do {
            let message = try await messageRepository.sendMessage(
                conversationId: conversationId,
                content: text,
                messageType: "text"
            )

            // Add to local messages
            messages.append(message)

            // Update conversation
            try? messageRepository.updateConversationWithNewMessage(message)

            // Stop typing indicator
            await stopTyping()
        } catch let error as APIError {
            errorMessage = error.errorDescription
            // Restore message on error
            messageText = text
        } catch {
            errorMessage = error.localizedDescription
            messageText = text
        }

        isSending = false
    }

    // MARK: - Typing Indicators

    func startTyping() async {
        guard !isTyping else { return }

        isTyping = true

        do {
            try await webSocketService.sendTypingIndicator(conversationId: conversationId, isTyping: true)
        } catch {
            // Silently fail for typing indicators
        }

        // Auto-stop typing after 3 seconds
        typingDebounceTask?.cancel()
        typingDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if !Task.isCancelled {
                await stopTyping()
            }
        }
    }

    func stopTyping() async {
        guard isTyping else { return }

        isTyping = false
        typingDebounceTask?.cancel()

        do {
            try await webSocketService.sendTypingIndicator(conversationId: conversationId, isTyping: false)
        } catch {
            // Silently fail
        }
    }

    func handleTextChanged() {
        Task {
            if !messageText.isEmpty && !isTyping {
                await startTyping()
            } else if messageText.isEmpty && isTyping {
                await stopTyping()
            }
        }
    }

    // MARK: - Read Receipts

    private func markMessagesAsRead() async {
        let unreadMessages = messages.filter { !$0.isRead && $0.senderId != currentUserId }

        for message in unreadMessages {
            try? await messageRepository.markMessageAsRead(messageId: message.id)

            // Send read receipt via WebSocket
            try? await webSocketService.sendReadReceipt(
                conversationId: conversationId,
                messageId: message.id
            )
        }

        // Reset unread count
        try? await messageRepository.resetUnreadCount(conversationId: conversationId)
    }

    // MARK: - WebSocket Integration

    private func setupWebSocketSubscriptions() {
        // Listen for new messages
        webSocketService.messageReceived
            .filter { [weak self] message in
                message.conversationId == self?.conversationId
            }
            .sink { [weak self] message in
                guard let self = self else { return }
                Task { @MainActor in
                    // Add message if not already present
                    if !self.messages.contains(where: { $0.id == message.id }) {
                        self.messages.append(message)

                        // Mark as read if not from current user
                        if message.senderId != self.currentUserId {
                            try? await self.messageRepository.markMessageAsRead(messageId: message.id)
                            try? await self.webSocketService.sendReadReceipt(
                                conversationId: self.conversationId,
                                messageId: message.id
                            )
                        }
                    }
                }
            }
            .store(in: &cancellables)

        // Listen for typing indicators
        webSocketService.typingEvent
            .filter { [weak self] event in
                event.conversationId == self?.conversationId &&
                event.userId != self?.currentUserId
            }
            .sink { [weak self] event in
                guard let self = self else { return }
                Task { @MainActor in
                    self.otherUserTyping = event.isTyping
                    self.otherUserTypingName = event.isTyping ? event.userName : nil
                }
            }
            .store(in: &cancellables)

        // Listen for read receipts
        webSocketService.readReceiptReceived
            .filter { [weak self] receipt in
                receipt.conversationId == self?.conversationId
            }
            .sink { [weak self] receipt in
                guard let self = self else { return }
                Task { @MainActor in
                    if let index = self.messages.firstIndex(where: { $0.id == receipt.messageId }) {
                        self.messages[index].isRead = true
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Message Grouping

    func shouldShowTimestamp(for index: Int) -> Bool {
        guard index >= 0 && index < messages.count else { return false }

        // Always show timestamp for first message
        if index == 0 { return true }

        let current = messages[index]
        let previous = messages[index - 1]

        // Show timestamp if messages are more than 5 minutes apart
        let timeDiff = current.timestamp.timeIntervalSince(previous.timestamp)
        return timeDiff > 300 // 5 minutes
    }

    func shouldShowAvatar(for index: Int) -> Bool {
        guard index >= 0 && index < messages.count else { return false }

        let current = messages[index]

        // Always show avatar for last message from a sender
        if index == messages.count - 1 { return true }

        let next = messages[index + 1]

        // Show avatar if next message is from different sender
        return current.senderId != next.senderId
    }

    // MARK: - Cleanup

    func cleanup() {
        Task {
            await stopTyping()
        }
    }
}
