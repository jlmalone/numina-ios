//
//  Group.swift
//  Numina
//
//  Group data models
//

import Foundation
import SwiftData

@Model
final class Group {
    @Attribute(.unique) var id: String
    var name: String
    var groupDescription: String
    var category: String // fitness, social, wellness, etc.
    var privacy: String // public, private
    var imageURL: String?
    var memberCount: Int
    var maxMembers: Int?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    var isJoined: Bool

    init(
        id: String,
        name: String,
        groupDescription: String,
        category: String,
        privacy: String = "public",
        imageURL: String? = nil,
        memberCount: Int = 0,
        maxMembers: Int? = nil,
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isJoined: Bool = false
    ) {
        self.id = id
        self.name = name
        self.groupDescription = groupDescription
        self.category = category
        self.privacy = privacy
        self.imageURL = imageURL
        self.memberCount = memberCount
        self.maxMembers = maxMembers
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isJoined = isJoined
    }
}

// MARK: - Codable DTO

struct GroupDTO: Codable {
    let id: String
    let name: String
    let description: String
    let category: String
    let privacy: String
    let imageURL: String?
    let memberCount: Int
    let maxMembers: Int?
    let location: GroupLocationDTO?
    let createdBy: String
    let createdAt: Date
    let updatedAt: Date
    let isJoined: Bool

    func toModel() -> Group {
        Group(
            id: id,
            name: name,
            groupDescription: description,
            category: category,
            privacy: privacy,
            imageURL: imageURL,
            memberCount: memberCount,
            maxMembers: maxMembers,
            locationName: location?.name,
            latitude: location?.latitude,
            longitude: location?.longitude,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isJoined: isJoined
        )
    }
}

extension Group {
    func toDTO() -> GroupDTO {
        let location = (locationName != nil && latitude != nil && longitude != nil) ? GroupLocationDTO(
            name: locationName!,
            latitude: latitude!,
            longitude: longitude!
        ) : nil

        return GroupDTO(
            id: id,
            name: name,
            description: groupDescription,
            category: category,
            privacy: privacy,
            imageURL: imageURL,
            memberCount: memberCount,
            maxMembers: maxMembers,
            location: location,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isJoined: isJoined
        )
    }

    var isFull: Bool {
        guard let max = maxMembers else { return false }
        return memberCount >= max
    }

    var formattedMemberCount: String {
        if let max = maxMembers {
            return "\(memberCount)/\(max) members"
        }
        return "\(memberCount) members"
    }
}

struct GroupLocationDTO: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
}

// MARK: - Group Member

@Model
final class GroupMember {
    @Attribute(.unique) var id: String
    var groupId: String
    var userId: String
    var userName: String
    var userPhotoURL: String?
    var role: String // admin, moderator, member
    var joinedAt: Date

    init(
        id: String,
        groupId: String,
        userId: String,
        userName: String,
        userPhotoURL: String? = nil,
        role: String = "member",
        joinedAt: Date = Date()
    ) {
        self.id = id
        self.groupId = groupId
        self.userId = userId
        self.userName = userName
        self.userPhotoURL = userPhotoURL
        self.role = role
        self.joinedAt = joinedAt
    }
}

struct GroupMemberDTO: Codable {
    let id: String
    let userId: String
    let userName: String
    let userPhotoURL: String?
    let role: String
    let joinedAt: Date

    func toModel(groupId: String) -> GroupMember {
        GroupMember(
            id: id,
            groupId: groupId,
            userId: userId,
            userName: userName,
            userPhotoURL: userPhotoURL,
            role: role,
            joinedAt: joinedAt
        )
    }
}

// MARK: - Group Activity

@Model
final class GroupActivity {
    @Attribute(.unique) var id: String
    var groupId: String
    var title: String
    var activityDescription: String
    var activityType: String // workout, social, event
    var scheduledTime: Date?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var fitnessClassId: String? // Link to fitness class
    var maxParticipants: Int?
    var rsvpCount: Int
    var userRSVP: String? // yes, no, maybe
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        groupId: String,
        title: String,
        activityDescription: String,
        activityType: String,
        scheduledTime: Date? = nil,
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        fitnessClassId: String? = nil,
        maxParticipants: Int? = nil,
        rsvpCount: Int = 0,
        userRSVP: String? = nil,
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.groupId = groupId
        self.title = title
        self.activityDescription = activityDescription
        self.activityType = activityType
        self.scheduledTime = scheduledTime
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.fitnessClassId = fitnessClassId
        self.maxParticipants = maxParticipants
        self.rsvpCount = rsvpCount
        self.userRSVP = userRSVP
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct GroupActivityDTO: Codable {
    let id: String
    let title: String
    let description: String
    let type: String
    let scheduledTime: Date?
    let location: GroupLocationDTO?
    let fitnessClassId: String?
    let maxParticipants: Int?
    let rsvpCount: Int
    let userRSVP: String?
    let createdBy: String
    let createdAt: Date
    let updatedAt: Date

    func toModel(groupId: String) -> GroupActivity {
        GroupActivity(
            id: id,
            groupId: groupId,
            title: title,
            activityDescription: description,
            activityType: type,
            scheduledTime: scheduledTime,
            locationName: location?.name,
            latitude: location?.latitude,
            longitude: location?.longitude,
            fitnessClassId: fitnessClassId,
            maxParticipants: maxParticipants,
            rsvpCount: rsvpCount,
            userRSVP: userRSVP,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension GroupActivity {
    var formattedScheduledTime: String? {
        guard let time = scheduledTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    var formattedRSVPCount: String {
        if let max = maxParticipants {
            return "\(rsvpCount)/\(max) attending"
        }
        return "\(rsvpCount) attending"
    }

    var isFull: Bool {
        guard let max = maxParticipants else { return false }
        return rsvpCount >= max
    }
}

// MARK: - List Responses

struct GroupListResponse: Codable {
    let groups: [GroupDTO]
    let total: Int
    let page: Int
    let limit: Int
}

struct GroupMemberListResponse: Codable {
    let members: [GroupMemberDTO]
    let total: Int
}

struct GroupActivityListResponse: Codable {
    let activities: [GroupActivityDTO]
    let total: Int
}

// MARK: - Create Group Request

struct CreateGroupRequest: Codable {
    let name: String
    let description: String
    let category: String
    let privacy: String
    let imageURL: String?
    let maxMembers: Int?
    let location: GroupLocationDTO?
}

// MARK: - Create Activity Request

struct CreateActivityRequest: Codable {
    let title: String
    let description: String
    let type: String
    let scheduledTime: Date?
    let location: GroupLocationDTO?
    let fitnessClassId: String?
    let maxParticipants: Int?
}

// MARK: - RSVP Request

struct RSVPRequest: Codable {
    let response: String // yes, no, maybe
}
