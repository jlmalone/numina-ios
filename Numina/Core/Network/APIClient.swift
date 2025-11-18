//
//  APIClient.swift
//  Numina
//
//  Main API client using URLSession with async/await
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .serverError(let statusCode, let message):
            return message ?? "Server error (\(statusCode))"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURL: String

    // Configurable base URL (can be changed for dev/prod)
    init(baseURL: String = "https://api.numina.app", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    // MARK: - Request Methods

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        var request = try buildRequest(endpoint: endpoint, body: body)

        if requiresAuth {
            try AuthInterceptor.shared.intercept(&request)
        }

        return try await perform(request: request)
    }

    func requestWithoutResponse(
        endpoint: APIEndpoint,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        var request = try buildRequest(endpoint: endpoint, body: body)

        if requiresAuth {
            try AuthInterceptor.shared.intercept(&request)
        }

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw mapHTTPError(statusCode: httpResponse.statusCode, data: nil)
        }
    }

    // MARK: - Private Helpers

    private func buildRequest(endpoint: APIEndpoint, body: Encodable?) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        // Add query parameters if needed
        if case .getClasses(let filters) = endpoint {
            urlComponents.queryItems = endpoint.queryItems(filters: filters)
        }

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add body if provided
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }

    private func perform<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw mapHTTPError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    private func mapHTTPError(statusCode: Int, data: Data?) -> APIError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 400...499, 500...599:
            let message = data.flatMap { try? JSONDecoder().decode(ErrorResponse.self, from: $0) }?.message
            return .serverError(statusCode: statusCode, message: message)
        default:
            return .unknown
        }
    }
}

// MARK: - Error Response Model

struct ErrorResponse: Decodable {
    let message: String
    let error: String?
}

// MARK: - Configuration

extension APIClient {
    /// Creates a client configured for development
    static func development() -> APIClient {
        return APIClient(baseURL: "http://localhost:3000")
    }

    /// Creates a client configured for staging
    static func staging() -> APIClient {
        return APIClient(baseURL: "https://staging-api.numina.app")
    }

    /// Creates a client configured for production
    static func production() -> APIClient {
        return APIClient(baseURL: "https://api.numina.app")
    }
}
