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

    // Messaging endpoints
    case getConversations
    case getConversation(id: String)
    case getMessages(conversationId: String)
    case sendMessage
    case createConversation
    case deleteConversation(id: String)
    case searchUsers(query: String)

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
        case .getConversations:
            return "/api/v1/messages/conversations"
        case .getConversation(let id):
            return "/api/v1/messages/conversations/\(id)"
        case .getMessages(let conversationId):
            return "/api/v1/messages/conversations/\(conversationId)/messages"
        case .sendMessage:
            return "/api/v1/messages/send"
        case .createConversation:
            return "/api/v1/messages/conversations"
        case .deleteConversation(let id):
            return "/api/v1/messages/conversations/\(id)"
        case .searchUsers(let query):
            return "/api/v1/users/search?q=\(query)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register, .login, .sendMessage, .createConversation:
            return .post
        case .getCurrentUser, .getClasses, .getClassDetails, .getConversations, .getConversation, .getMessages, .searchUsers:
            return .get
        case .updateCurrentUser:
            return .put
        case .deleteConversation:
            return .delete
        }
    }

    func queryItems(filters: ClassFilters?) -> [URLQueryItem]? {
        switch self {
        case .getClasses(let filters):
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
