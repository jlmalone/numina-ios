//
//  AuthInterceptor.swift
//  Numina
//
//  Intercepts requests to add JWT authentication
//

import Foundation

final class AuthInterceptor {
    static let shared = AuthInterceptor()

    private init() {}

    func intercept(_ request: inout URLRequest) throws {
        // Try to get the auth token from Keychain
        if let token = try? KeychainHelper.shared.retrieveAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    func addAuthHeader(_ request: inout URLRequest, token: String) {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
