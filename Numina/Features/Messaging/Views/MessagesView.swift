//
//  MessagesView.swift
//  Numina
//
//  List view for conversations
//

import SwiftUI

struct MessagesView: View {
    @StateObject var viewModel: MessagesViewModel
    @State private var showingNewChat = false
    @State private var selectedConversation: Conversation?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.conversations.isEmpty {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.conversations.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadConversations()
                        }
                    }
                } else if viewModel.conversations.isEmpty {
                    EmptyMessagesView(onStartChat: {
                        showingNewChat = true
                    })
                } else {
                    conversationListContent
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewChat = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.orange)
                    }
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search conversations")
            .sheet(isPresented: $showingNewChat) {
                NewChatView(viewModel: viewModel)
            }
            .sheet(item: $selectedConversation) { conversation in
                // Get current user ID from UserDefaults or auth state
                // For now, use a placeholder
                if let currentUserId = KeychainHelper.shared.getUserId() {
                    ChatViewWrapper(
                        conversation: conversation,
                        currentUserId: currentUserId
                    )
                }
            }
            .task {
                if viewModel.conversations.isEmpty {
                    await viewModel.connectWebSocket()
                    await viewModel.loadConversations()
                }
            }
            .onDisappear {
                viewModel.disconnectWebSocket()
            }
        }
    }

    private var conversationListContent: some View {
        List {
            ForEach(viewModel.filteredConversations, id: \.id) { conversation in
                ConversationRow(conversation: conversation)
                    .onTapGesture {
                        selectedConversation = conversation
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteConversation(id: conversation.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            viewModel.archiveConversation(id: conversation.id)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(.orange)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshConversations()
        }
        .overlay(alignment: .topTrailing) {
            // Unread count badge
            if viewModel.totalUnreadCount > 0 {
                Text("\(viewModel.totalUnreadCount)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(minWidth: 24, minHeight: 24)
                    .padding(.horizontal, 8)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .padding()
            }
        }
    }
}

// MARK: - Chat View Wrapper

struct ChatViewWrapper: View {
    let conversation: Conversation
    let currentUserId: String

    var body: some View {
        // Need to get model context from environment
        ChatView(
            viewModel: ChatViewModel(
                conversationId: conversation.id,
                currentUserId: currentUserId,
                messageRepository: MessageRepository()
            )
        )
    }
}

// MARK: - Empty Messages View

struct EmptyMessagesView: View {
    let onStartChat: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))

            Text("No Messages Yet")
                .font(.title3.weight(.medium))

            Text("Start a conversation with your workout buddies")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onStartChat) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Start New Chat")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

// MARK: - KeychainHelper Extension for User ID

extension KeychainHelper {
    func getUserId() -> String? {
        // In a real implementation, this would retrieve the user ID from Keychain
        // For now, return a placeholder
        return "current-user-id"
    }
}

// MARK: - Preview

#Preview {
    MessagesView(
        viewModel: MessagesViewModel(
            messageRepository: MessageRepository()
        )
    )
}
