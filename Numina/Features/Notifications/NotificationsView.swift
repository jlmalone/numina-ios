//
//  NotificationsView.swift
//  Numina
//
//  Main notification center view
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject var viewModel: NotificationsViewModel
    @ObservedObject var notificationService: NotificationService

    @State private var selectedFilter: NotificationType?
    @State private var showingPreferences = false

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }

                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { selectedFilter = nil }) {
                            Label("All", systemImage: selectedFilter == nil ? "checkmark" : "")
                        }

                        ForEach(NotificationType.allCases, id: \.self) { type in
                            Button(action: { selectedFilter = type }) {
                                Label(type.displayName, systemImage: selectedFilter == type ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            Task {
                                await viewModel.markAllAsRead()
                            }
                        }) {
                            Label("Mark All as Read", systemImage: "checkmark.circle")
                        }
                        .disabled(!viewModel.hasUnread)

                        Button(action: {
                            showingPreferences = true
                        }) {
                            Label("Preferences", systemImage: "gear")
                        }

                        Button(role: .destructive, action: {
                            viewModel.clearAll()
                        }) {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingPreferences) {
                NavigationView {
                    NotificationPreferencesView(viewModel: viewModel, notificationService: notificationService)
                }
            }
            .refreshable {
                await viewModel.fetchNotificationHistory()
            }
            .onAppear {
                viewModel.loadLocalNotifications()
            }
        }
    }

    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredNotifications) { notification in
                    VStack(spacing: 0) {
                        NotificationRow(notification: notification) {
                            handleNotificationTap(notification)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteNotification(notification)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            if !notification.isRead {
                                Button {
                                    Task {
                                        await viewModel.markAsRead(notification)
                                    }
                                } label: {
                                    Label("Read", systemImage: "checkmark")
                                }
                                .tint(.blue)
                            }
                        }

                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: notificationService.authorizationStatus == .authorized ? "bell.slash" : "bell.badge")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(emptyStateTitle)
                .font(.title3)
                .fontWeight(.semibold)

            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if notificationService.authorizationStatus != .authorized {
                Button(action: {
                    Task {
                        try? await notificationService.requestAuthorization()
                    }
                }) {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
        }
    }

    private var emptyStateTitle: String {
        switch notificationService.authorizationStatus {
        case .notDetermined, .denied:
            return "Notifications Disabled"
        default:
            return "No Notifications"
        }
    }

    private var emptyStateMessage: String {
        switch notificationService.authorizationStatus {
        case .notDetermined:
            return "Enable notifications to stay updated on messages, matches, and more."
        case .denied:
            return "Notifications are disabled. Enable them in Settings to stay updated."
        default:
            return "You're all caught up! Check back later for new updates."
        }
    }

    private var filteredNotifications: [AppNotification] {
        if let filter = selectedFilter {
            return viewModel.notifications.filter { $0.notificationType == filter }
        }
        return viewModel.notifications
    }

    private func handleNotificationTap(_ notification: AppNotification) {
        Task {
            if !notification.isRead {
                await viewModel.markAsRead(notification)
            }

            // Handle navigation based on notification type
            if let relatedID = notification.relatedID {
                switch notification.notificationType {
                case .message:
                    print("Navigate to message: \(relatedID)")
                case .match:
                    print("Navigate to match: \(relatedID)")
                case .group:
                    print("Navigate to group: \(relatedID)")
                case .reminder:
                    print("Navigate to class: \(relatedID)")
                }
            }
        }
    }
}

#Preview {
    NotificationsView(
        viewModel: NotificationsViewModel(modelContext: ModelContext(try! ModelContainer(for: AppNotification.self))),
        notificationService: NotificationService(modelContext: ModelContext(try! ModelContainer(for: AppNotification.self)))
    )
}
