//
//  Review.swift
//  Numina
//
//  Review data model for class and trainer reviews
//

import Foundation
import SwiftData

@Model
final class Review {
    @Attribute(.unique) var id: String
    var classId: String
    var userId: String
    var userName: String
    var userPhotoURL: String?
    var rating: Int // 1-5 stars
    var reviewText: String
    var pros: [String]
    var cons: [String]
    var photoURLs: [String]
    var helpfulCount: Int
    var isHelpfulByCurrentUser: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        classId: String,
        userId: String,
        userName: String,
        userPhotoURL: String? = nil,
        rating: Int,
        reviewText: String,
        pros: [String] = [],
        cons: [String] = [],
        photoURLs: [String] = [],
        helpfulCount: Int = 0,
        isHelpfulByCurrentUser: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.classId = classId
        self.userId = userId
        self.userName = userName
        self.userPhotoURL = userPhotoURL
        self.rating = rating
        self.reviewText = reviewText
        self.pros = pros
        self.cons = cons
        self.photoURLs = photoURLs
        self.helpfulCount = helpfulCount
        self.isHelpfulByCurrentUser = isHelpfulByCurrentUser
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Codable DTO

struct ReviewDTO: Codable {
    let id: String
    let classId: String
    let userId: String
    let userName: String
    let userPhotoURL: String?
    let rating: Int
    let reviewText: String
    let pros: [String]
    let cons: [String]
    let photoURLs: [String]
    let helpfulCount: Int
    let isHelpfulByCurrentUser: Bool
    let createdAt: Date
    let updatedAt: Date

    func toModel() -> Review {
        Review(
            id: id,
            classId: classId,
            userId: userId,
            userName: userName,
            userPhotoURL: userPhotoURL,
            rating: rating,
            reviewText: reviewText,
            pros: pros,
            cons: cons,
            photoURLs: photoURLs,
            helpfulCount: helpfulCount,
            isHelpfulByCurrentUser: isHelpfulByCurrentUser,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Review {
    func toDTO() -> ReviewDTO {
        ReviewDTO(
            id: id,
            classId: classId,
            userId: userId,
            userName: userName,
            userPhotoURL: userPhotoURL,
            rating: rating,
            reviewText: reviewText,
            pros: pros,
            cons: cons,
            photoURLs: photoURLs,
            helpfulCount: helpfulCount,
            isHelpfulByCurrentUser: isHelpfulByCurrentUser,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    var isRecent: Bool {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return daysSinceCreation <= 7
    }
}

// MARK: - Review Request/Response Models

struct CreateReviewRequest: Codable {
    let rating: Int
    let reviewText: String
    let pros: [String]
    let cons: [String]
    let photoURLs: [String]
}

struct UpdateReviewRequest: Codable {
    let rating: Int?
    let reviewText: String?
    let pros: [String]?
    let cons: [String]?
    let photoURLs: [String]?
}

struct ReviewListResponse: Codable {
    let reviews: [ReviewDTO]
    let total: Int
    let averageRating: Double
    let page: Int
    let limit: Int
}

struct MarkHelpfulResponse: Codable {
    let success: Bool
    let helpfulCount: Int
}

// MARK: - Review Sorting

enum ReviewSortOption: String, CaseIterable, Identifiable {
    case mostRecent = "Most Recent"
    case mostHelpful = "Most Helpful"
    case highestRated = "Highest Rated"
    case lowestRated = "Lowest Rated"

    var id: String { rawValue }

    var queryValue: String {
        switch self {
        case .mostRecent:
            return "recent"
        case .mostHelpful:
            return "helpful"
        case .highestRated:
            return "rating_desc"
        case .lowestRated:
            return "rating_asc"
        }
    }
}
