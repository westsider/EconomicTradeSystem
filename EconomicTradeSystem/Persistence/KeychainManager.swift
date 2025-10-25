//
//  KeychainManager.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation
import Security

enum KeychainError: Error {
    case duplicateItem
    case unknown(OSStatus)
    case itemNotFound
    case invalidData
}

class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    // MARK: - Save API Key
    func save(key: String, value: String) throws {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }

    // MARK: - Retrieve API Key
    func retrieve(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unknown(status)
        }

        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return value
    }

    // MARK: - Delete API Key
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }

    // MARK: - Check if Key Exists
    func exists(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Convenience Methods for Polygon API Key
    func savePolygonAPIKey(_ key: String) throws {
        try save(key: "polygon_api_key", value: key)
    }

    func getPolygonAPIKey() throws -> String {
        try retrieve(key: "polygon_api_key")
    }

    func hasPolygonAPIKey() -> Bool {
        exists(key: "polygon_api_key")
    }

    func deletePolygonAPIKey() throws {
        try delete(key: "polygon_api_key")
    }

    // MARK: - Convenience Methods for FRED API Key
    func saveFREDAPIKey(_ key: String) throws {
        try save(key: "fred_api_key", value: key)
    }

    func getFREDAPIKey() throws -> String {
        try retrieve(key: "fred_api_key")
    }

    func hasFREDAPIKey() -> Bool {
        exists(key: "fred_api_key")
    }

    func deleteFREDAPIKey() throws {
        try delete(key: "fred_api_key")
    }
}
