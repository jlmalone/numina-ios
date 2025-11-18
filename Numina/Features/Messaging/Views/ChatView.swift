//
//  ChatView.swift
//  Numina
//
//  Individual chat view with real-time messaging
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages list
                messagesContent

                // Typing indicator
                if viewModel.otherUserTyping {
                    typingIndicatorView
                }

                // Message input
                messageInputView
            }
            .navigationTitle(viewModel.conversation?.displayName ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.orange)
                    }
                }
            }
            .task {
                await viewModel.loadMessages()
            }
            .onDisappear {
                viewModel.cleanup()
            }
        }
    }

    private var messagesContent: some View {
        Group {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.messages.isEmpty {
                ErrorView(message: errorMessage) {
                    Task {
                        await viewModel.loadMessages()
                    }
                }
            } else if viewModel.messages.isEmpty {
                emptyMessagesView
            } else {
                messagesList
            }
        }
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                        MessageBubble(
                            message: message,
                            isFromCurrentUser: message.senderId == viewModel.currentUserId,
                            showAvatar: viewModel.shouldShowAvatar(for: index),
                            showTimestamp: viewModel.shouldShowTimestamp(for: index)
                        )
                        .id(message.id)
                    }

                    // Invisible anchor for auto-scroll
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                // Auto-scroll to bottom when new messages arrive
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onAppear {
                // Scroll to bottom on first load
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }

    private var emptyMessagesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange.opacity(0.5))

            Text("No messages yet")
                .font(.title3.weight(.medium))

            Text("Start the conversation!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }

    private var typingIndicatorView: some View {
        HStack(spacing: 8) {
            TypingIndicator()

            if let userName = viewModel.otherUserTypingName {
                Text("\(userName) is typing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    private var messageInputView: some View {
        HStack(spacing: 12) {
            // Text field
            TextField("Message", text: $viewModel.messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .lineLimit(1...5)
                .focused($isTextFieldFocused)
                .onChange(of: viewModel.messageText) { _, _ in
                    viewModel.handleTextChanged()
                }
                .disabled(viewModel.isSending)

            // Send button
            Button(action: {
                Task {
                    await viewModel.sendMessage()
                    isTextFieldFocused = true
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                            LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 36, height: 36)

                    if viewModel.isSending {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

// MARK: - Preview

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            conversationId: "conv1",
            currentUserId: "user1",
            messageRepository: MessageRepository()
        )
    )
}
