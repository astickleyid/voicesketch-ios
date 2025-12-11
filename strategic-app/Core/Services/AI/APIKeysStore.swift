//
//  APIKeysStore.swift
//  VoiceSketch
//

import Foundation
import Security

actor APIKeysStore {
    static let shared = APIKeysStore()
    private init() {}
    
    private func keychainQuery(for provider: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.voicesketch.aiKeys",
            kSecAttrAccount as String: provider
        ]
    }
    
    func save(apiKey: String, for provider: String) async throws {
        let data = Data(apiKey.utf8)
        var query = keychainQuery(for: provider)
        query[kSecValueData as String] = data
        
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = keychainQuery(for: provider)
            addQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw NSError(domain: "APIKeysStore", code: Int(addStatus), userInfo: nil)
            }
        } else if status != errSecSuccess {
            throw NSError(domain: "APIKeysStore", code: Int(status), userInfo: nil)
        }
    }
    
    func getKey(for provider: String) async -> String? {
        var query = keychainQuery(for: provider)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data, let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }
    
    func deleteKey(for provider: String) {
        let query = keychainQuery(for: provider)
        SecItemDelete(query as CFDictionary)
    }
}
