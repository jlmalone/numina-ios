//
//  AuthViewModel.swift
//  Numina
//
//  ViewModel for authentication
//

import Foundation
import SwiftData

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        checkAuthStatus()
    }

    // MARK: - Check Auth Status

    func checkAuthStatus() {
        // Check if we have a token stored
        do {
            let token = try KeychainHelper.shared.retrieveAuthToken()
            isAuthenticated = !token.isEmpty

            // Try to load cached user
            if isAuthenticated {
                Task {
                    await loadCurrentUser()
                }
            }
        } catch {
            isAuthenticated = false
        }
    }

    // MARK: - Register

    func register(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await userRepository.register(email: email, password: password, name: name)
            currentUser = response.user.toModel()
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Login

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await userRepository.login(email: email, password: password)
            currentUser = response.user.toModel()
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Logout

    func logout() {
        do {
            try userRepository.logout()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Load Current User

    func loadCurrentUser() async {
        do {
            currentUser = try await userRepository.getCurrentUser(fromCache: true)
        } catch {
            // Failed to load user, might need to re-authenticate
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Validation

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    func isValidName(_ name: String) -> Bool {
        return name.count >= 2
    }
}
