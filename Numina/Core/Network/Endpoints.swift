//
//  Endpoints.swift
//  Numina
//
//  API endpoint definitions
//

import Foundation

enum APIEndpoint {
    case register
    case login
    case getCurrentUser
    case updateCurrentUser
    case getClasses(filters: ClassFilters?)
    case getClassDetails(id: String)
    case getReviews(classId: String, sort: String?, page: Int?, limit: Int?)
    case createReview(classId: String)
    case updateReview(reviewId: String)
    case deleteReview(reviewId: String)
    case markReviewHelpful(reviewId: String)
    case getMyReviews
    case getPendingReviews

    // Social endpoints
    case getFeed(page: Int, limit: Int)
    case followUser(userId: String)
    case unfollowUser(userId: String)
    case discoverUsers(filters: UserSearchFilters?)
    case getUserProfile(userId: String)
    case likeActivity(activityId: String)
    case unlikeActivity(activityId: String)
    case commentOnActivity(activityId: String)
    case getActivityComments(activityId: String)
    case getFollowers(userId: String)
    case getFollowing(userId: String)

    var path: String {
        switch self {
        case .register:
            return "/api/v1/auth/register"
        case .login:
            return "/api/v1/auth/login"
        case .getCurrentUser:
            return "/api/v1/users/me"
        case .updateCurrentUser:
            return "/api/v1/users/me"
        case .getClasses:
            return "/api/v1/classes"
        case .getClassDetails(let id):
            return "/api/v1/classes/\(id)"

        // Social paths
        case .getFeed:
            return "/api/v1/social/feed"
        case .followUser(let userId):
            return "/api/v1/social/follow/\(userId)"
        case .unfollowUser(let userId):
            return "/api/v1/social/unfollow/\(userId)"
        case .discoverUsers:
            return "/api/v1/social/discover-users"
        case .getUserProfile(let userId):
            return "/api/v1/social/users/\(userId)/profile"
        case .likeActivity(let activityId):
            return "/api/v1/social/activity/\(activityId)/like"
        case .unlikeActivity(let activityId):
            return "/api/v1/social/activity/\(activityId)/like"
        case .commentOnActivity(let activityId):
            return "/api/v1/social/activity/\(activityId)/comment"
        case .getActivityComments(let activityId):
            return "/api/v1/social/activity/\(activityId)/comments"
        case .getFollowers(let userId):
            return "/api/v1/social/users/\(userId)/followers"
        case .getFollowing(let userId):
            return "/api/v1/social/users/\(userId)/following"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register, .login, .createReview, .markReviewHelpful:
            return .post
        case .getCurrentUser, .getClasses, .getClassDetails, .getReviews, .getMyReviews, .getPendingReviews:
            return .get
        case .updateCurrentUser, .updateReview:
            return .put

        // Social methods
        case .getFeed, .discoverUsers, .getUserProfile, .getActivityComments, .getFollowers, .getFollowing:
            return .get
        case .followUser, .likeActivity, .commentOnActivity:
            return .post
        case .unfollowUser, .unlikeActivity:
            return .delete
        }
    }

    func queryItems(filters: ClassFilters?) -> [URLQueryItem]? {
        switch self {
        case .getClasses(let filters):
            return filters?.toQueryItems()
        case .getFeed(let page, let limit):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        case .discoverUsers(let filters):
            return filters?.toQueryItems()
        default:
            return nil
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Class Filters

struct ClassFilters {
    var startDate: Date?
    var endDate: Date?
    var locationRadius: Double?
    var latitude: Double?
    var longitude: Double?
    var classType: String?
    var minPrice: Double?
    var maxPrice: Double?
    var page: Int?
    var limit: Int?

    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let startDate = startDate {
            items.append(URLQueryItem(name: "startDate", value: ISO8601DateFormatter().string(from: startDate)))
        }
        if let endDate = endDate {
            items.append(URLQueryItem(name: "endDate", value: ISO8601DateFormatter().string(from: endDate)))
        }
        if let radius = locationRadius {
            items.append(URLQueryItem(name: "radius", value: String(radius)))
        }
        if let lat = latitude {
            items.append(URLQueryItem(name: "lat", value: String(lat)))
        }
        if let lon = longitude {
            items.append(URLQueryItem(name: "lon", value: String(lon)))
        }
        if let type = classType, !type.isEmpty {
            items.append(URLQueryItem(name: "type", value: type))
        }
        if let min = minPrice {
            items.append(URLQueryItem(name: "minPrice", value: String(min)))
        }
        if let max = maxPrice {
            items.append(URLQueryItem(name: "maxPrice", value: String(max)))
        }
        if let page = page {
            items.append(URLQueryItem(name: "page", value: String(page)))
        }
        if let limit = limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }

        return items
    }
}

// MARK: - User Search Filters Extension

extension UserSearchFilters {
    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let query = query, !query.isEmpty {
            items.append(URLQueryItem(name: "query", value: query))
        }
        if let interests = fitnessInterests, !interests.isEmpty {
            items.append(URLQueryItem(name: "interests", value: interests.joined(separator: ",")))
        }
        if let level = fitnessLevel {
            items.append(URLQueryItem(name: "fitnessLevel", value: String(level)))
        }
        if let location = location {
            items.append(URLQueryItem(name: "lat", value: String(location.latitude)))
            items.append(URLQueryItem(name: "lon", value: String(location.longitude)))
            items.append(URLQueryItem(name: "radius", value: String(location.radiusMiles)))
        }
        items.append(URLQueryItem(name: "page", value: String(page)))
        items.append(URLQueryItem(name: "limit", value: String(limit)))

        return items
    }
}
