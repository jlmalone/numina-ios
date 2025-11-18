//
//  WebSocketService.swift
//  Numina
//
//  WebSocket service for real-time messaging
//

import Foundation
import Combine

enum WebSocketError: LocalizedError {
    case invalidURL
    case connectionFailed(Error)
    case authenticationFailed
    case disconnected
    case sendFailed(Error)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .connectionFailed(let error):
            return "Connection failed: \(error.localizedDescription)"
        case .authenticationFailed:
            return "WebSocket authentication failed"
        case .disconnected:
            return "WebSocket disconnected"
        case .sendFailed(let error):
            return "Failed to send message: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode message: \(error.localizedDescription)"
        }
    }
}

final class WebSocketService: NSObject {
    static let shared = WebSocketService()

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private let baseURL: String
    private var isConnected = false
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5

    // Publishers for real-time events
    let messageReceived = PassthroughSubject<MessageDTO, Never>()
    let typingEvent = PassthroughSubject<(conversationId: String, userId: String, userName: String, isTyping: Bool), Never>()
    let readReceiptReceived = PassthroughSubject<(conversationId: String, messageId: String, userId: String), Never>()
    let connectionStateChanged = PassthroughSubject<Bool, Never>()
    let errorOccurred = PassthroughSubject<WebSocketError, Never>()

    init(baseURL: String = "wss://api.numina.app") {
        self.baseURL = baseURL
        super.init()
        setupSession()
    }

    // MARK: - Connection Management

    private func setupSession() {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }

    func connect() async throws {
        guard !isConnected else { return }

        guard let url = URL(string: "\(baseURL)/api/v1/ws/messages") else {
            throw WebSocketError.invalidURL
        }

        var request = URLRequest(url: url)

        // Add JWT token for authentication
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw WebSocketError.authenticationFailed
        }

        webSocketTask = session?.webSocketTask(with: request)
        webSocketTask?.resume()

        isConnected = true
        reconnectAttempts = 0
        connectionStateChanged.send(true)

        // Start receiving messages
        receiveMessage()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        connectionStateChanged.send(false)
    }

    // MARK: - Sending Messages

    func send(message: String, to conversationId: String) async throws {
        guard isConnected else {
            throw WebSocketError.disconnected
        }

        let event = OutgoingWebSocketEvent(
            type: "send_message",
            data: OutgoingEventData(
                conversationId: conversationId,
                content: message,
                messageType: "text"
            )
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(event)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""

        let message = URLSessionWebSocketTask.Message.string(jsonString)

        do {
            try await webSocketTask?.send(message)
        } catch {
            throw WebSocketError.sendFailed(error)
        }
    }

    func sendTypingIndicator(conversationId: String, isTyping: Bool) async throws {
        guard isConnected else { return }

        let event = OutgoingWebSocketEvent(
            type: isTyping ? "typing_start" : "typing_stop",
            data: OutgoingEventData(
                conversationId: conversationId,
                content: nil,
                messageType: nil
            )
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(event)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""

        let message = URLSessionWebSocketTask.Message.string(jsonString)

        try? await webSocketTask?.send(message)
    }

    func sendReadReceipt(conversationId: String, messageId: String) async throws {
        guard isConnected else { return }

        let event = OutgoingWebSocketEvent(
            type: "mark_read",
            data: OutgoingEventData(
                conversationId: conversationId,
                content: messageId,
                messageType: nil
            )
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(event)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""

        let message = URLSessionWebSocketTask.Message.string(jsonString)

        try? await webSocketTask?.send(message)
    }

    // MARK: - Receiving Messages

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                self.handleReceivedMessage(message)
                // Continue listening for more messages
                if self.isConnected {
                    self.receiveMessage()
                }

            case .failure(let error):
                self.handleError(error)
            }
        }
    }

    private func handleReceivedMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            parseAndDispatchEvent(from: text)

        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                parseAndDispatchEvent(from: text)
            }

        @unknown default:
            break
        }
    }

    private func parseAndDispatchEvent(from jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let event = try decoder.decode(WebSocketMessageEvent.self, from: data)

            switch event.type {
            case "new_message":
                if let message = event.data.message {
                    messageReceived.send(message)
                }

            case "typing_start", "typing_stop":
                if let conversationId = event.data.conversationId,
                   let userId = event.data.userId,
                   let userName = event.data.userName {
                    typingEvent.send((
                        conversationId: conversationId,
                        userId: userId,
                        userName: userName,
                        isTyping: event.type == "typing_start"
                    ))
                }

            case "read_receipt":
                if let conversationId = event.data.conversationId,
                   let message = event.data.message,
                   let userId = event.data.userId {
                    readReceiptReceived.send((
                        conversationId: conversationId,
                        messageId: message.id,
                        userId: userId
                    ))
                }

            default:
                break
            }
        } catch {
            errorOccurred.send(.decodingFailed(error))
        }
    }

    private func handleError(_ error: Error) {
        isConnected = false
        connectionStateChanged.send(false)
        errorOccurred.send(.connectionFailed(error))

        // Attempt to reconnect
        if reconnectAttempts < maxReconnectAttempts {
            reconnectAttempts += 1
            Task {
                try? await Task.sleep(nanoseconds: UInt64(reconnectAttempts * 2) * 1_000_000_000) // Exponential backoff
                try? await connect()
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        connectionStateChanged.send(true)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        connectionStateChanged.send(false)

        // Attempt to reconnect if not intentionally closed
        if closeCode != .goingAway && reconnectAttempts < maxReconnectAttempts {
            reconnectAttempts += 1
            Task {
                try? await Task.sleep(nanoseconds: UInt64(reconnectAttempts * 2) * 1_000_000_000)
                try? await connect()
            }
        }
    }
}

// MARK: - Outgoing Event Models

private struct OutgoingWebSocketEvent: Codable {
    let type: String
    let data: OutgoingEventData
}

private struct OutgoingEventData: Codable {
    let conversationId: String
    let content: String?
    let messageType: String?
}

// MARK: - Configuration

extension WebSocketService {
    static func development() -> WebSocketService {
        return WebSocketService(baseURL: "ws://localhost:3000")
    }

    static func staging() -> WebSocketService {
        return WebSocketService(baseURL: "wss://staging-api.numina.app")
    }

    static func production() -> WebSocketService {
        return WebSocketService(baseURL: "wss://api.numina.app")
    }
}
