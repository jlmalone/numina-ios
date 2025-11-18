import SwiftUI

/// Generic empty state view for lists and collections
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: {
                    HapticFeedback.shared.buttonPress()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                .accessibilityLabel(actionTitle)
            }
        }
        .padding(40)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Predefined Empty States

extension EmptyStateView {

    /// Empty state for no classes found
    static func noClasses(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "dumbbell",
            title: "No Classes Found",
            message: "There are no classes available right now. Try adjusting your filters or check back later.",
            actionTitle: action != nil ? "Clear Filters" : nil,
            action: action
        )
    }

    /// Empty state for no messages
    static func noMessages(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "message",
            title: "No Messages",
            message: "You don't have any conversations yet. Start chatting with other members!",
            actionTitle: action != nil ? "Start a Conversation" : nil,
            action: action
        )
    }

    /// Empty state for no groups
    static func noGroups(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "person.3",
            title: "No Groups Found",
            message: "There are no groups available. Create your own group or adjust your search.",
            actionTitle: action != nil ? "Create Group" : nil,
            action: action
        )
    }

    /// Empty state for no activities
    static func noActivities() -> EmptyStateView {
        EmptyStateView(
            icon: "sparkles",
            title: "No Activities Yet",
            message: "Follow other users or join groups to see activities in your feed.",
            actionTitle: nil,
            action: nil
        )
    }

    /// Empty state for no reviews
    static func noReviews(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "star",
            title: "No Reviews Yet",
            message: "Be the first to review this class and help others make informed decisions!",
            actionTitle: action != nil ? "Write a Review" : nil,
            action: action
        )
    }

    /// Empty state for no user reviews
    static func noUserReviews() -> EmptyStateView {
        EmptyStateView(
            icon: "star.fill",
            title: "No Reviews Yet",
            message: "You haven't written any reviews. Share your fitness class experiences!",
            actionTitle: nil,
            action: nil
        )
    }

    /// Empty state for no notifications
    static func noNotifications() -> EmptyStateView {
        EmptyStateView(
            icon: "bell",
            title: "No Notifications",
            message: "You're all caught up! You'll see notifications here when something happens.",
            actionTitle: nil,
            action: nil
        )
    }

    /// Empty state for no followers
    static func noFollowers() -> EmptyStateView {
        EmptyStateView(
            icon: "person.2",
            title: "No Followers",
            message: "You don't have any followers yet. Stay active and share your fitness journey!",
            actionTitle: nil,
            action: nil
        )
    }

    /// Empty state for no following
    static func noFollowing(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "person.2.fill",
            title: "Not Following Anyone",
            message: "Discover and follow other fitness enthusiasts to see their activities.",
            actionTitle: action != nil ? "Discover Users" : nil,
            action: action
        )
    }

    /// Empty state for search results
    static func noSearchResults() -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: "Try different search terms or filters to find what you're looking for.",
            actionTitle: nil,
            action: nil
        )
    }

    /// Empty state for pending reviews
    static func noPendingReviews() -> EmptyStateView {
        EmptyStateView(
            icon: "checkmark.circle",
            title: "All Caught Up!",
            message: "You don't have any pending reviews. All your reviews are up to date.",
            actionTitle: nil,
            action: nil
        )
    }

    /// Empty state for bookings (when implemented)
    static func noBookings(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "calendar",
            title: "No Bookings",
            message: "You don't have any bookings yet. Book a class to get started!",
            actionTitle: action != nil ? "Browse Classes" : nil,
            action: action
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 40) {
            EmptyStateView.noClasses()
            Divider()
            EmptyStateView.noMessages()
            Divider()
            EmptyStateView.noGroups(action: { print("Create group") })
        }
    }
}
