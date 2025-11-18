# TASK: Add Messaging UI to Numina iOS App

> **IMPORTANT**: Check for `.task-messaging-ui-completed` before starting.
> **When finished**, create `.task-messaging-ui-completed` file.

## 🎯 OBJECTIVE

Build complete messaging interface with real-time chat using SwiftUI.

## 📋 REQUIREMENTS

### Features
1. **Conversations List**
   - List all conversations with preview
   - Unread count badges
   - Avatar, last message, timestamp
   - Swipe to delete/archive
   - Pull-to-refresh

2. **Chat Interface**
   - Real-time messaging via WebSocket/URLSession
   - Message bubbles (sent/received styling)
   - Timestamps
   - Read receipts
   - Typing indicators
   - Auto-scroll to latest
   - Image attachments (optional)

3. **User Search**
   - Find users to start new conversations
   - Search by name, fitness interests
   - Recently matched users

### Files to Create
- `MessagesView.swift` - Conversations list
- `ChatView.swift` - Individual chat
- `NewChatView.swift` - Start new conversation
- `MessageBubble.swift` - Message component
- `ConversationRow.swift` - List item
- `MessagesViewModel.swift` - State management
- `ChatViewModel.swift` - WebSocket integration
- `WebSocketService.swift` - WebSocket handling

### API Integration
- `GET /api/v1/messages/conversations`
- `GET /api/v1/messages/conversations/{id}`
- `POST /api/v1/messages/send`
- `WS /api/v1/ws/messages`

### Local Storage
- SwiftData entities for messages/conversations
- Offline message queue
- Sync on launch

### WebSocket
- URLSessionWebSocketTask for real-time
- Reconnection logic
- Authentication with JWT

## ✅ ACCEPTANCE CRITERIA

- [ ] Conversations list displays correctly
- [ ] Real-time messaging works
- [ ] Messages persist in SwiftData
- [ ] Typing indicators visible
- [ ] Unread counts accurate
- [ ] New conversation flow works
- [ ] Dark mode supported
- [ ] iOS 15+ compatible

## 📝 DELIVERABLES

- Messaging views and components
- ViewModels with WebSocket
- SwiftData models
- Repository layer
- Navigation integration
- Tests

## 🚀 COMPLETION

1. Build in Xcode
2. Test on simulator
3. Create `.task-messaging-ui-completed`
4. Commit: "Add messaging UI with real-time chat"
5. Push: `git push -u origin claude/add-messaging-ui`

---

**Est. Time**: 75-90 min | **Priority**: HIGH
