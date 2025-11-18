//
//  AuthViewModelTests.swift
//  NuminaTests
//
//  Unit tests for AuthViewModel
//

import XCTest
@testable import Numina

@MainActor
final class AuthViewModelTests: XCTestCase {
    var viewModel: AuthViewModel!
    var mockRepository: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        viewModel = AuthViewModel(userRepository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Email Validation Tests

    func testIsValidEmail_WithValidEmail_ReturnsTrue() {
        XCTAssertTrue(viewModel.isValidEmail("test@example.com"))
        XCTAssertTrue(viewModel.isValidEmail("user.name@domain.co.uk"))
        XCTAssertTrue(viewModel.isValidEmail("user+tag@example.com"))
    }

    func testIsValidEmail_WithInvalidEmail_ReturnsFalse() {
        XCTAssertFalse(viewModel.isValidEmail(""))
        XCTAssertFalse(viewModel.isValidEmail("notanemail"))
        XCTAssertFalse(viewModel.isValidEmail("@example.com"))
        XCTAssertFalse(viewModel.isValidEmail("user@"))
    }

    // MARK: - Password Validation Tests

    func testIsValidPassword_WithValidPassword_ReturnsTrue() {
        XCTAssertTrue(viewModel.isValidPassword("password123"))
        XCTAssertTrue(viewModel.isValidPassword("123456"))
        XCTAssertTrue(viewModel.isValidPassword("abcdef"))
    }

    func testIsValidPassword_WithInvalidPassword_ReturnsFalse() {
        XCTAssertFalse(viewModel.isValidPassword(""))
        XCTAssertFalse(viewModel.isValidPassword("12345"))
        XCTAssertFalse(viewModel.isValidPassword("abc"))
    }

    // MARK: - Name Validation Tests

    func testIsValidName_WithValidName_ReturnsTrue() {
        XCTAssertTrue(viewModel.isValidName("John Doe"))
        XCTAssertTrue(viewModel.isValidName("Jo"))
        XCTAssertTrue(viewModel.isValidName("Mary Jane"))
    }

    func testIsValidName_WithInvalidName_ReturnsFalse() {
        XCTAssertFalse(viewModel.isValidName(""))
        XCTAssertFalse(viewModel.isValidName("A"))
    }

    // MARK: - Login Tests

    func testLogin_Success_SetsAuthenticatedState() async {
        let email = "test@example.com"
        let password = "password123"

        mockRepository.loginResult = .success(AuthResponse(
            token: "fake-token",
            refreshToken: nil,
            user: UserDTO.mockUser()
        ))

        await viewModel.login(email: email, password: password)

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLogin_Failure_SetsErrorMessage() async {
        let email = "test@example.com"
        let password = "wrongpassword"

        mockRepository.loginResult = .failure(APIError.unauthorized)

        await viewModel.login(email: email, password: password)

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.currentUser)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Register Tests

    func testRegister_Success_SetsAuthenticatedState() async {
        let email = "new@example.com"
        let password = "password123"
        let name = "New User"

        mockRepository.registerResult = .success(AuthResponse(
            token: "fake-token",
            refreshToken: nil,
            user: UserDTO.mockUser()
        ))

        await viewModel.register(email: email, password: password, name: name)

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}

// MARK: - Mock User Repository

class MockUserRepository: UserRepository {
    var loginResult: Result<AuthResponse, Error> = .failure(APIError.unknown)
    var registerResult: Result<AuthResponse, Error> = .failure(APIError.unknown)

    override func login(email: String, password: String) async throws -> AuthResponse {
        switch loginResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }

    override func register(email: String, password: String, name: String) async throws -> AuthResponse {
        switch registerResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Mock Data Extensions

extension UserDTO {
    static func mockUser() -> UserDTO {
        UserDTO(
            id: "1",
            email: "test@example.com",
            name: "Test User",
            bio: "Test bio",
            photoURL: nil,
            fitnessInterests: ["Yoga", "HIIT"],
            fitnessLevel: 5,
            latitude: 37.7749,
            longitude: -122.4194,
            locationName: "San Francisco",
            availability: [],
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
