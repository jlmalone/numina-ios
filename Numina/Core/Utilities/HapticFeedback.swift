import UIKit

/// Utility class for providing haptic feedback throughout the app
final class HapticFeedback {

    /// Shared instance
    static let shared = HapticFeedback()

    private init() {}

    // MARK: - Impact Feedback

    /// Light impact feedback for button taps and minor interactions
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact feedback for pull-to-refresh and moderate interactions
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact feedback for significant interactions
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Soft impact feedback for gentle interactions (iOS 13+)
    @available(iOS 13.0, *)
    func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    /// Rigid impact feedback for firm interactions (iOS 13+)
    @available(iOS 13.0, *)
    func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success notification feedback
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification feedback
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification feedback
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed feedback (for pickers, sliders, etc.)
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Prepared Feedback (for better performance)

    /// Prepare impact feedback generator for better responsiveness
    func prepareImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> UIImpactFeedbackGenerator {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        return generator
    }

    /// Prepare notification feedback generator for better responsiveness
    func prepareNotification() -> UINotificationFeedbackGenerator {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        return generator
    }

    /// Prepare selection feedback generator for better responsiveness
    func prepareSelection() -> UISelectionFeedbackGenerator {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        return generator
    }
}

// MARK: - Convenience Extensions

extension HapticFeedback {

    /// Haptic feedback for button press
    func buttonPress() {
        light()
    }

    /// Haptic feedback for toggle switch
    func toggleSwitch() {
        selection()
    }

    /// Haptic feedback for pull-to-refresh start
    func refreshStart() {
        medium()
    }

    /// Haptic feedback for pull-to-refresh complete
    func refreshComplete() {
        if #available(iOS 13.0, *) {
            soft()
        } else {
            light()
        }
    }

    /// Haptic feedback for form submission
    func formSubmit() {
        medium()
    }

    /// Haptic feedback for form validation error
    func formError() {
        error()
    }

    /// Haptic feedback for successful action
    func actionSuccess() {
        success()
    }

    /// Haptic feedback for failed action
    func actionFailed() {
        error()
    }

    /// Haptic feedback for deletion
    func deletion() {
        warning()
    }

    /// Haptic feedback for navigation
    func navigation() {
        if #available(iOS 13.0, *) {
            soft()
        } else {
            light()
        }
    }

    /// Haptic feedback for like/favorite
    func favorite() {
        if #available(iOS 13.0, *) {
            rigid()
        } else {
            medium()
        }
    }

    /// Haptic feedback for message sent
    func messageSent() {
        success()
    }

    /// Haptic feedback for rating stars
    func ratingChange() {
        selection()
    }
}
