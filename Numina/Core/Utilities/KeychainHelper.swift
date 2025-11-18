//
//  KeychainHelper.swift
//  Numina
//
//  Secure storage for JWT tokens and sensitive data
//

import Foundation
import Security

enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case itemNotFound
    case invalidData
}

final class KeychainHelper {
    static let shared = KeychainHelper()

    private init() {}

    private let service = "com.numina.app"

    // MARK: - Save

    func save(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status != errSecDuplicateItem else {
            // Item exists, update it
            try update(data, for: key)
            return
        }

        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }

    func save(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        try save(data, for: key)
    }

    // MARK: - Retrieve

    func retrieve(for key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw status == errSecItemNotFound ? KeychainError.itemNotFound : KeychainError.unknown(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return data
    }

    func retrieveString(for key: String) throws -> String {
        let data = try retrieve(for: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        return string
    }

    // MARK: - Update

    private func update(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }

    // MARK: - Delete

    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }

    func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
}

// MARK: - Convenience Extensions for Auth Tokens

extension KeychainHelper {
    private static let tokenKey = "auth_token"
    private static let refreshTokenKey = "refresh_token"

    func saveAuthToken(_ token: String) throws {
        try save(token, for: Self.tokenKey)
    }

    func retrieveAuthToken() throws -> String {
        try retrieveString(for: Self.tokenKey)
    }

    func deleteAuthToken() throws {
        try delete(for: Self.tokenKey)
    }

    func saveRefreshToken(_ token: String) throws {
        try save(token, for: Self.refreshTokenKey)
    }

    func retrieveRefreshToken() throws -> String {
        try retrieveString(for: Self.refreshTokenKey)
    }

    func deleteRefreshToken() throws {
        try delete(for: Self.refreshTokenKey)
    }

    func clearAllTokens() throws {
        try? deleteAuthToken()
        try? deleteRefreshToken()
    }
}
