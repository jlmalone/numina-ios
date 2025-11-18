//
//  Activity.swift
//  Numina
//
//  Social activity feed model
//

import Foundation
import SwiftData

@Model
final class Activity {
    @Attribute(.unique) var id: String
    var userId: String
    var userName: String
    var userPhotoURL: String?
    var activityType: String // "class_completed", "achievement", "goal_reached", etc.
    var title: String
    var activityDescription: String?
    var classId: String?
    var className: String?
    var classType: String?
    var imageURL: String?
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool
    var createdAt: Date

    init(
        id: String,
        userId: String,
        userName: String,
        userPhotoURL: String? = nil,
        activityType: String,
        title: String,
        activityDescription: String? = nil,
        classId: String? = nil,
        className: String? = nil,
        classType: String? = nil,
        imageURL: String? = nil,
        likesCount: Int = 0,
        commentsCount: Int = 0,
        isLiked: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userPhotoURL = userPhotoURL
        self.activityType = activityType
        self.title = title
        self.activityDescription = activityDescription
        self.classId = classId
        self.className = className
        self.classType = classType
        self.imageURL = imageURL
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = isLiked
        self.createdAt = createdAt
    }
}

// MARK: - Codable Activity DTO

struct ActivityDTO: Codable {
    let id: String
    let user: ActivityUserDTO
    let activityType: String
    let title: String
    let description: String?
    let classInfo: ActivityClassInfoDTO?
    let imageURL: String?
    let likesCount: Int
    let commentsCount: Int
    let isLiked: Bool
    let createdAt: Date

    func toModel() -> Activity {
        Activity(
            id: id,
            userId: user.id,
            userName: user.name,
            userPhotoURL: user.photoURL,
            activityType: activityType,
            title: title,
            activityDescription: description,
            classId: classInfo?.id,
            className: classInfo?.name,
            classType: classInfo?.type,
            imageURL: imageURL,
            likesCount: likesCount,
            commentsCount: commentsCount,
            isLiked: isLiked,
            createdAt: createdAt
        )
    }
}

extension Activity {
    func toDTO() -> ActivityDTO {
        ActivityDTO(
            id: id,
            user: ActivityUserDTO(
                id: userId,
                name: userName,
                photoURL: userPhotoURL
            ),
            activityType: activityType,
            title: title,
            description: activityDescription,
            classInfo: classId != nil ? ActivityClassInfoDTO(
                id: classId!,
                name: className ?? "",
                type: classType
            ) : nil,
            imageURL: imageURL,
            likesCount: likesCount,
            commentsCount: commentsCount,
            isLiked: isLiked,
            createdAt: createdAt
        )
    }

    var timeAgoDisplay: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: createdAt, to: now)

        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Supporting Models

struct ActivityUserDTO: Codable {
    let id: String
    let name: String
    let photoURL: String?
}

struct ActivityClassInfoDTO: Codable {
    let id: String
    let name: String
    let type: String?
}

// MARK: - Comment Model

@Model
final class Comment {
    @Attribute(.unique) var id: String
    var activityId: String
    var userId: String
    var userName: String
    var userPhotoURL: String?
    var text: String
    var createdAt: Date

    init(
        id: String,
        activityId: String,
        userId: String,
        userName: String,
        userPhotoURL: String? = nil,
        text: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.activityId = activityId
        self.userId = userId
        self.userName = userName
        self.userPhotoURL = userPhotoURL
        self.text = text
        self.createdAt = createdAt
    }
}

struct CommentDTO: Codable {
    let id: String
    let activityId: String
    let user: ActivityUserDTO
    let text: String
    let createdAt: Date

    func toModel() -> Comment {
        Comment(
            id: id,
            activityId: activityId,
            userId: user.id,
            userName: user.name,
            userPhotoURL: user.photoURL,
            text: text,
            createdAt: createdAt
        )
    }
}

extension Comment {
    func toDTO() -> CommentDTO {
        CommentDTO(
            id: id,
            activityId: activityId,
            user: ActivityUserDTO(
                id: userId,
                name: userName,
                photoURL: userPhotoURL
            ),
            text: text,
            createdAt: createdAt
        )
    }
}

// MARK: - Feed Response

struct FeedResponse: Codable {
    let activities: [ActivityDTO]
    let total: Int
    let page: Int
    let limit: Int
}

// MARK: - Comment Request

struct CommentRequest: Codable {
    let text: String
}

// MARK: - Comments Response

struct CommentsResponse: Codable {
    let comments: [CommentDTO]
    let total: Int
}
