import SwiftUI

/// Enhanced AsyncImage with placeholder and shimmer loading
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    var body: some View {
        if let url = url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    SkeletonView()
                case .success(let image):
                    content(image)
                case .failure:
                    placeholder()
                @unknown default:
                    placeholder()
                }
            }
        } else {
            placeholder()
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Content == some View, Placeholder == some View {
    /// Initialize with URL string and default placeholders
    init(
        urlString: String?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = urlString != nil ? URL(string: urlString!) : nil
        self.content = content
        self.placeholder = placeholder
    }
}

// MARK: - Avatar Image View

/// Circular avatar image with loading state
struct AvatarImage: View {
    let imageURL: String?
    let size: CGFloat
    let placeholderIcon: String

    init(
        imageURL: String?,
        size: CGFloat = 50,
        placeholderIcon: String = "person.circle.fill"
    ) {
        self.imageURL = imageURL
        self.size = size
        self.placeholderIcon = placeholderIcon
    }

    var body: some View {
        CachedAsyncImage(
            url: imageURL != nil ? URL(string: imageURL!) : nil,
            content: { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            },
            placeholder: {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: size, height: size)

                    Image(systemName: placeholderIcon)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: size * 0.6, height: size * 0.6)
                }
            }
        )
        .accessibilityLabel("Profile picture")
    }
}

// MARK: - Card Image View

/// Rectangular card image with loading state
struct CardImage: View {
    let imageURL: String?
    let height: CGFloat
    let cornerRadius: CGFloat
    let placeholderIcon: String

    init(
        imageURL: String?,
        height: CGFloat = 160,
        cornerRadius: CGFloat = 12,
        placeholderIcon: String = "photo"
    ) {
        self.imageURL = imageURL
        self.height = height
        self.cornerRadius = cornerRadius
        self.placeholderIcon = placeholderIcon
    }

    var body: some View {
        CachedAsyncImage(
            url: imageURL != nil ? URL(string: imageURL!) : nil,
            content: { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .clipped()
                    .cornerRadius(cornerRadius)
            },
            placeholder: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: height)
                        .cornerRadius(cornerRadius)

                    VStack(spacing: 8) {
                        Image(systemName: placeholderIcon)
                            .font(.system(size: 40))
                            .foregroundColor(.gray)

                        Text("Image unavailable")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        )
        .accessibilityLabel("Card image")
    }
}

// MARK: - Class Image View

/// Image view specifically for fitness class cards
struct ClassImage: View {
    let imageURL: String?
    let height: CGFloat

    init(imageURL: String?, height: CGFloat = 160) {
        self.imageURL = imageURL
        self.height = height
    }

    var body: some View {
        CardImage(
            imageURL: imageURL,
            height: height,
            cornerRadius: 12,
            placeholderIcon: "dumbbell"
        )
        .accessibilityLabel("Class image")
    }
}

// MARK: - Group Image View

/// Image view specifically for group cards
struct GroupImage: View {
    let imageURL: String?
    let size: CGFloat

    init(imageURL: String?, size: CGFloat = 60) {
        self.imageURL = imageURL
        self.size = size
    }

    var body: some View {
        AvatarImage(
            imageURL: imageURL,
            size: size,
            placeholderIcon: "person.3.fill"
        )
        .accessibilityLabel("Group image")
    }
}

// MARK: - Review Photo Thumbnail

/// Small thumbnail for review photos
struct ReviewPhotoThumbnail: View {
    let imageURL: String
    let size: CGFloat

    init(imageURL: String, size: CGFloat = 80) {
        self.imageURL = imageURL
        self.size = size
    }

    var body: some View {
        CachedAsyncImage(
            url: URL(string: imageURL),
            content: { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
                    .cornerRadius(8)
            },
            placeholder: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: size, height: size)
                        .cornerRadius(8)

                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
            }
        )
        .accessibilityLabel("Review photo")
    }
}

#Preview {
    VStack(spacing: 20) {
        AvatarImage(imageURL: nil, size: 80)

        ClassImage(imageURL: nil, height: 200)

        GroupImage(imageURL: nil, size: 60)

        HStack(spacing: 12) {
            ReviewPhotoThumbnail(imageURL: "invalid", size: 80)
            ReviewPhotoThumbnail(imageURL: "invalid", size: 80)
            ReviewPhotoThumbnail(imageURL: "invalid", size: 80)
        }
    }
    .padding()
}
