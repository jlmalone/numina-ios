//
//  APIClientTests.swift
//  NuminaTests
//
//  Unit tests for APIClient
//

import XCTest
@testable import Numina

final class APIClientTests: XCTestCase {
    var apiClient: APIClient!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        apiClient = APIClient(baseURL: "https://api.test.com", session: mockSession)
    }

    override func tearDown() {
        apiClient = nil
        mockSession = nil
        super.tearDown()
    }

    // MARK: - Endpoint Tests

    func testEndpoint_Register_HasCorrectPath() {
        let endpoint = APIEndpoint.register
        XCTAssertEqual(endpoint.path, "/api/v1/auth/register")
        XCTAssertEqual(endpoint.method, .post)
    }

    func testEndpoint_Login_HasCorrectPath() {
        let endpoint = APIEndpoint.login
        XCTAssertEqual(endpoint.path, "/api/v1/auth/login")
        XCTAssertEqual(endpoint.method, .post)
    }

    func testEndpoint_GetCurrentUser_HasCorrectPath() {
        let endpoint = APIEndpoint.getCurrentUser
        XCTAssertEqual(endpoint.path, "/api/v1/users/me")
        XCTAssertEqual(endpoint.method, .get)
    }

    func testEndpoint_GetClasses_HasCorrectPath() {
        let endpoint = APIEndpoint.getClasses(filters: nil)
        XCTAssertEqual(endpoint.path, "/api/v1/classes")
        XCTAssertEqual(endpoint.method, .get)
    }

    func testEndpoint_GetClassDetails_HasCorrectPath() {
        let endpoint = APIEndpoint.getClassDetails(id: "123")
        XCTAssertEqual(endpoint.path, "/api/v1/classes/123")
        XCTAssertEqual(endpoint.method, .get)
    }

    // MARK: - Class Filters Tests

    func testClassFilters_ToQueryItems_ConvertsAllFilters() {
        let startDate = Date()
        let endDate = Date().addingTimeInterval(7 * 24 * 60 * 60)

        var filters = ClassFilters()
        filters.startDate = startDate
        filters.endDate = endDate
        filters.locationRadius = 10.0
        filters.latitude = 37.7749
        filters.longitude = -122.4194
        filters.classType = "Yoga"
        filters.minPrice = 10.0
        filters.maxPrice = 50.0
        filters.page = 1
        filters.limit = 20

        let queryItems = filters.toQueryItems()

        XCTAssertTrue(queryItems.contains(where: { $0.name == "radius" && $0.value == "10.0" }))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "lat" && $0.value == "37.7749" }))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "lon" && $0.value == "-122.4194" }))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "type" && $0.value == "Yoga" }))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "minPrice" && $0.value == "10.0" }))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "maxPrice" && $0.value == "50.0" }))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "page" && $0.value == "1" }))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "limit" && $0.value == "20" }))
    }

    // MARK: - API Error Tests

    func testAPIError_InvalidURL_HasCorrectDescription() {
        let error = APIError.invalidURL
        XCTAssertEqual(error.errorDescription, "Invalid URL")
    }

    func testAPIError_Unauthorized_HasCorrectDescription() {
        let error = APIError.unauthorized
        XCTAssertEqual(error.errorDescription, "Unauthorized. Please log in again.")
    }

    func testAPIError_ServerError_HasCorrectDescription() {
        let error = APIError.serverError(statusCode: 500, message: "Internal Server Error")
        XCTAssertEqual(error.errorDescription, "Internal Server Error")
    }

    func testAPIError_ServerError_WithNoMessage_UsesDefaultDescription() {
        let error = APIError.serverError(statusCode: 404, message: nil)
        XCTAssertEqual(error.errorDescription, "Server error (404)")
    }
}

// MARK: - Mock URL Session

class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        let data = mockData ?? Data()
        let response = mockResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        return (data, response)
    }
}
