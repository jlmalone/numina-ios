import SwiftUI

/// A skeleton loading view with shimmer animation
struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

/// Skeleton view for a class card
struct SkeletonClassCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder
            SkeletonView()
                .frame(height: 160)

            VStack(alignment: .leading, spacing: 8) {
                // Title
                SkeletonView()
                    .frame(height: 20)
                    .frame(maxWidth: .infinity)

                // Subtitle
                SkeletonView()
                    .frame(height: 16)
                    .frame(maxWidth: 200)

                HStack {
                    // Rating
                    SkeletonView()
                        .frame(width: 80, height: 16)

                    Spacer()

                    // Price
                    SkeletonView()
                        .frame(width: 60, height: 16)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// Skeleton view for a group card
struct SkeletonGroupCard: View {
    var body: some View {
        HStack(spacing: 12) {
            // Image
            SkeletonView()
                .frame(width: 60, height: 60)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                // Title
                SkeletonView()
                    .frame(height: 18)
                    .frame(maxWidth: 200)

                // Subtitle
                SkeletonView()
                    .frame(height: 14)
                    .frame(maxWidth: 150)

                // Members count
                SkeletonView()
                    .frame(width: 100, height: 14)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// Skeleton view for a message/conversation item
struct SkeletonMessageRow: View {
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            SkeletonView()
                .frame(width: 50, height: 50)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    // Name
                    SkeletonView()
                        .frame(height: 16)
                        .frame(maxWidth: 150)

                    Spacer()

                    // Time
                    SkeletonView()
                        .frame(width: 50, height: 14)
                }

                // Message preview
                SkeletonView()
                    .frame(height: 14)
                    .frame(maxWidth: 250)
            }
        }
        .padding(.vertical, 8)
    }
}

/// Skeleton view for an activity feed item
struct SkeletonActivityItem: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // User avatar
                SkeletonView()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    // User name
                    SkeletonView()
                        .frame(height: 16)
                        .frame(maxWidth: 150)

                    // Time
                    SkeletonView()
                        .frame(width: 80, height: 12)
                }

                Spacer()
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                SkeletonView()
                    .frame(height: 14)
                    .frame(maxWidth: .infinity)

                SkeletonView()
                    .frame(height: 14)
                    .frame(maxWidth: 280)
            }

            // Action buttons
            HStack(spacing: 20) {
                SkeletonView()
                    .frame(width: 60, height: 14)

                SkeletonView()
                    .frame(width: 60, height: 14)

                SkeletonView()
                    .frame(width: 60, height: 14)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// Skeleton view for a profile header
struct SkeletonProfileHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            SkeletonView()
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            // Name
            SkeletonView()
                .frame(height: 24)
                .frame(maxWidth: 200)

            // Bio
            SkeletonView()
                .frame(height: 16)
                .frame(maxWidth: 300)

            // Stats row
            HStack(spacing: 40) {
                ForEach(0..<3) { _ in
                    VStack(spacing: 4) {
                        SkeletonView()
                            .frame(width: 50, height: 20)

                        SkeletonView()
                            .frame(width: 60, height: 14)
                    }
                }
            }
        }
        .padding()
    }
}

/// Skeleton view for a review item
struct SkeletonReviewRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // User avatar
                SkeletonView()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    // User name
                    SkeletonView()
                        .frame(height: 16)
                        .frame(maxWidth: 120)

                    // Rating stars
                    SkeletonView()
                        .frame(width: 100, height: 14)
                }

                Spacer()

                // Date
                SkeletonView()
                    .frame(width: 70, height: 12)
            }

            // Review text
            VStack(alignment: .leading, spacing: 4) {
                SkeletonView()
                    .frame(height: 14)
                    .frame(maxWidth: .infinity)

                SkeletonView()
                    .frame(height: 14)
                    .frame(maxWidth: 250)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        SkeletonClassCard()
        SkeletonGroupCard()
        SkeletonMessageRow()
        SkeletonActivityItem()
    }
    .padding()
}
