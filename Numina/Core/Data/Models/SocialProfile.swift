//
//  SocialProfile.swift
//  Numina
//
//  Social profile and following models
//

import Foundation
import SwiftData

@Model
final class SocialProfile {
    @Attribute(.unique) var id: String
    var name: String
    var bio: String?
    var photoURL: String?
    var fitnessInterests: [String]
    var fitnessLevel: Int
    var locationName: String?
    var followersCount: Int
    var followingCount: Int
    var classesAttended: Int
    var isFollowing: Bool
    var isFollowedBy: Bool // Does this user follow me?
    var isMutualConnection: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        name: String,
        bio: String? = nil,
        photoURL: String? = nil,
        fitnessInterests: [String] = [],
        fitnessLevel: Int = 5,
        locationName: String? = nil,
        followersCount: Int = 0,
        followingCount: Int = 0,
        classesAttended: Int = 0,
        isFollowing: Bool = false,
        isFollowedBy: Bool = false,
        isMutualConnection: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.bio = bio
        self.photoURL = photoURL
        self.fitnessInterests = fitnessInterests
        self.fitnessLevel = fitnessLevel
        self.locationName = locationName
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.classesAttended = classesAttended
        self.isFollowing = isFollowing
        self.isFollowedBy = isFollowedBy
        self.isMutualConnection = isMutualConnection
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Codable SocialProfile DTO

struct SocialProfileDTO: Codable {
    let id: String
    let name: String
    let bio: String?
    let photoURL: String?
    let fitnessInterests: [String]
    let fitnessLevel: Int
    let locationName: String?
    let stats: SocialStatsDTO
    let followStatus: FollowStatusDTO?
    let createdAt: Date
    let updatedAt: Date

    func toModel() -> SocialProfile {
        SocialProfile(
            id: id,
            name: name,
            bio: bio,
            photoURL: photoURL,
            fitnessInterests: fitnessInterests,
            fitnessLevel: fitnessLevel,
            locationName: locationName,
            followersCount: stats.followersCount,
            followingCount: stats.followingCount,
            classesAttended: stats.classesAttended,
            isFollowing: followStatus?.isFollowing ?? false,
            isFollowedBy: followStatus?.isFollowedBy ?? false,
            isMutualConnection: followStatus?.isMutualConnection ?? false,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension SocialProfile {
    func toDTO() -> SocialProfileDTO {
        SocialProfileDTO(
            id: id,
            name: name,
            bio: bio,
            photoURL: photoURL,
            fitnessInterests: fitnessInterests,
            fitnessLevel: fitnessLevel,
            locationName: locationName,
            stats: SocialStatsDTO(
                followersCount: followersCount,
                followingCount: followingCount,
                classesAttended: classesAttended
            ),
            followStatus: FollowStatusDTO(
                isFollowing: isFollowing,
                isFollowedBy: isFollowedBy,
                isMutualConnection: isMutualConnection
            ),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var fitnessLevelDescription: String {
        switch fitnessLevel {
        case 1...3:
            return "Beginner"
        case 4...6:
            return "Intermediate"
        case 7...9:
            return "Advanced"
        case 10:
            return "Elite"
        default:
            return "Unknown"
        }
    }

    var connectionStatus: String {
        if isMutualConnection {
            return "Mutual Connection"
        } else if isFollowedBy {
            return "Follows You"
        } else {
            return ""
        }
    }
}

// MARK: - Supporting Models

struct SocialStatsDTO: Codable {
    let followersCount: Int
    let followingCount: Int
    let classesAttended: Int
}

struct FollowStatusDTO: Codable {
    let isFollowing: Bool
    let isFollowedBy: Bool
    let isMutualConnection: Bool
}

// MARK: - Discover Users Response

struct DiscoverUsersResponse: Codable {
    let users: [SocialProfileDTO]
    let total: Int
    let page: Int
    let limit: Int
}

// MARK: - Followers/Following Response

struct FollowListResponse: Codable {
    let users: [SocialProfileDTO]
    let total: Int
}

// MARK: - Follow Response

struct FollowResponse: Codable {
    let success: Bool
    let isFollowing: Bool
}

// MARK: - User Search Filters

struct UserSearchFilters: Codable {
    let query: String?
    let fitnessInterests: [String]?
    let fitnessLevel: Int?
    let location: LocationFilterDTO?
    let page: Int
    let limit: Int

    init(
        query: String? = nil,
        fitnessInterests: [String]? = nil,
        fitnessLevel: Int? = nil,
        location: LocationFilterDTO? = nil,
        page: Int = 1,
        limit: Int = 20
    ) {
        self.query = query
        self.fitnessInterests = fitnessInterests
        self.fitnessLevel = fitnessLevel
        self.location = location
        self.page = page
        self.limit = limit
    }
}

struct LocationFilterDTO: Codable {
    let latitude: Double
    let longitude: Double
    let radiusMiles: Double
}
