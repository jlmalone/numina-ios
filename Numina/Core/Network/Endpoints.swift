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
        case .getReviews(let classId, _, _, _):
            return "/api/v1/reviews/classes/\(classId)"
        case .createReview(let classId):
            return "/api/v1/reviews/classes/\(classId)"
        case .updateReview(let reviewId):
            return "/api/v1/reviews/\(reviewId)"
        case .deleteReview(let reviewId):
            return "/api/v1/reviews/\(reviewId)"
        case .markReviewHelpful(let reviewId):
            return "/api/v1/reviews/\(reviewId)/helpful"
        case .getMyReviews:
            return "/api/v1/reviews/my-reviews"
        case .getPendingReviews:
            return "/api/v1/reviews/pending"
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
        case .deleteReview:
            return .delete
        }
    }

    func queryItems(filters: ClassFilters?) -> [URLQueryItem]? {
        switch self {
        case .getClasses(let filters):
            return filters?.toQueryItems()
        case .getReviews(_, let sort, let page, let limit):
            var items: [URLQueryItem] = []
            if let sort = sort {
                items.append(URLQueryItem(name: "sort", value: sort))
            }
            if let page = page {
                items.append(URLQueryItem(name: "page", value: String(page)))
            }
            if let limit = limit {
                items.append(URLQueryItem(name: "limit", value: String(limit)))
            }
            return items.isEmpty ? nil : items
        default:
            return nil
        }
    }

    func queryItems(filters: GroupFilters?) -> [URLQueryItem]? {
        switch self {
        case .getGroups(let filters):
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

// MARK: - Group Filters

struct GroupFilters {
    var category: String?
    var search: String?
    var locationRadius: Double?
    var latitude: Double?
    var longitude: Double?
    var minSize: Int?
    var maxSize: Int?
    var privacy: String? // public, private
    var page: Int?
    var limit: Int?

    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let category = category, !category.isEmpty {
            items.append(URLQueryItem(name: "category", value: category))
        }
        if let search = search, !search.isEmpty {
            items.append(URLQueryItem(name: "search", value: search))
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
        if let minSize = minSize {
            items.append(URLQueryItem(name: "minSize", value: String(minSize)))
        }
        if let maxSize = maxSize {
            items.append(URLQueryItem(name: "maxSize", value: String(maxSize)))
        }
        if let privacy = privacy, !privacy.isEmpty {
            items.append(URLQueryItem(name: "privacy", value: privacy))
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
