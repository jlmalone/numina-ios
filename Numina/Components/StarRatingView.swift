//
//  StarRatingView.swift
//  Numina
//
//  Star rating input and display component
//

import SwiftUI

struct StarRatingView: View {
    let rating: Int
    let maxRating: Int
    let size: CGFloat
    let interactive: Bool
    let onRatingChanged: ((Int) -> Void)?

    init(
        rating: Int,
        maxRating: Int = 5,
        size: CGFloat = 20,
        interactive: Bool = false,
        onRatingChanged: ((Int) -> Void)? = nil
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.size = size
        self.interactive = interactive
        self.onRatingChanged = onRatingChanged
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundStyle(index <= rating ? .yellow : .gray.opacity(0.3))
                    .font(.system(size: size))
                    .onTapGesture {
                        if interactive {
                            onRatingChanged?(index)
                        }
                    }
            }
        }
    }
}

// MARK: - Previews

#Preview("Display Rating") {
    VStack(spacing: 20) {
        StarRatingView(rating: 5, size: 24)
        StarRatingView(rating: 4, size: 24)
        StarRatingView(rating: 3, size: 24)
        StarRatingView(rating: 2, size: 24)
        StarRatingView(rating: 1, size: 24)
    }
    .padding()
}

#Preview("Interactive Rating") {
    struct InteractiveRatingDemo: View {
        @State private var rating = 3

        var body: some View {
            VStack(spacing: 20) {
                Text("Tap to rate: \(rating) stars")
                    .font(.headline)

                StarRatingView(
                    rating: rating,
                    size: 32,
                    interactive: true,
                    onRatingChanged: { newRating in
                        rating = newRating
                    }
                )
            }
            .padding()
        }
    }

    return InteractiveRatingDemo()
}
