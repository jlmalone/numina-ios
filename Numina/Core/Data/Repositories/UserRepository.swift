//
//  UserRepository.swift
//  Numina
//
//  Repository for user data operations
//

import Foundation
import SwiftData

final class UserRepository {
    private let apiClient: APIClient
    private let modelContext: ModelContext?

    init(apiClient: APIClient = .shared, modelContext: ModelContext? = nil) {
        self.apiClient = apiClient
        self.modelContext = modelContext
    }

    // MARK: - Authentication

    func register(email: String, password: String, name: String) async throws -> AuthResponse {
        let request = RegisterRequest(email: email, password: password, name: name)
        let response: AuthResponse = try await apiClient.request(
            endpoint: .register,
            body: request,
            requiresAuth: false
        )

        // Save token to keychain
        try KeychainHelper.shared.saveAuthToken(response.token)
        if let refreshToken = response.refreshToken {
            try KeychainHelper.shared.saveRefreshToken(refreshToken)
        }

        // Cache user locally
        try await cacheUser(response.user.toModel())

        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await apiClient.request(
            endpoint: .login,
            body: request,
            requiresAuth: false
        )

        // Save token to keychain
        try KeychainHelper.shared.saveAuthToken(response.token)
        if let refreshToken = response.refreshToken {
            try KeychainHelper.shared.saveRefreshToken(refreshToken)
        }

        // Cache user locally
        try await cacheUser(response.user.toModel())

        return response
    }

    func logout() throws {
        try KeychainHelper.shared.clearAllTokens()
        try clearCachedUser()
    }

    // MARK: - User Profile

    func getCurrentUser(fromCache: Bool = false) async throws -> User {
        if fromCache, let cachedUser = try getCachedUser() {
            return cachedUser
        }

        let userDTO: UserDTO = try await apiClient.request(endpoint: .getCurrentUser)
        let user = userDTO.toModel()

        // Update cache
        try await cacheUser(user)

        return user
    }

    func updateProfile(request: UpdateProfileRequest) async throws -> User {
        let userDTO: UserDTO = try await apiClient.request(
            endpoint: .updateCurrentUser,
            body: request
        )
        let user = userDTO.toModel()

        // Update cache
        try await cacheUser(user)

        return user
    }

    // MARK: - Local Cache

    @MainActor
    private func cacheUser(_ user: User) throws {
        guard let context = modelContext else { return }

        // Remove existing user
        try clearCachedUser()

        // Insert new user
        context.insert(user)
        try context.save()
    }

    private func getCachedUser() throws -> User? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<User>()
        let users = try context.fetch(descriptor)
        return users.first
    }

    @MainActor
    private func clearCachedUser() throws {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<User>()
        let users = try context.fetch(descriptor)

        for user in users {
            context.delete(user)
        }

        try context.save()
    }
}
