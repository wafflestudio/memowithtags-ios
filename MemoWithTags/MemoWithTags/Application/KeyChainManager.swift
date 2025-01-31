//
//  KeyChainManager.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/3/25.
//

import Foundation
import Security

/// deviceId, accessToken, refreshtoken 관리
final class KeyChainManager {
    /// singleton
    static let shared = KeyChainManager()
    private init() {}
    
    private let service = "com.memoWithTags.service"
    
    // MARK: - Access Token Methods
    
    /// Keychain에 Access Token 저장, 이미 존재한다면 덮어씀
    func saveAccessToken(token: String) -> Bool {
        let account = "accessToken"
        guard let data = token.data(using: .utf8) else { return false }
        return save(service: service, account: account, data: data)
    }
    
    /// Keychain에서 Access Token 불러오기
    func readAccessToken() -> String? {
        let account = "accessToken"
        guard let data = read(service: service, account: account) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Keychain에서 Access Token 삭제하기
    func deleteAccessToken() -> Bool {
        let account = "accessToken"
        return delete(service: service, account: account)
    }
    
    // MARK: - Refresh Token Methods
    
    /// Keychain에 Refresh Token 저장
    func saveRefreshToken(token: String) -> Bool {
        let account = "refreshToken"
        guard let data = token.data(using: .utf8) else { return false }
        return save(service: service, account: account, data: data)
    }
    
    /// Keychain에서 Refresh Token 불러오기
    func readRefreshToken() -> String? {
        let account = "refreshToken"
        guard let data = read(service: service, account: account) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Keychain에서 Refresh Token 삭제하기
    func deleteRefreshToken() -> Bool {
        let account = "refreshToken"
        return delete(service: service, account: account)
    }
    
    // MARK: - Device ID Methods
    
    /// Keychain에 Device ID 저장, 이미 존재한다면 반환
    var deviceId: String {
        if let id = readDeviceId() {
            return id
        } else {
            let newID = UUID().uuidString
            let success = saveDeviceId(id: newID)
            return success ? newID : UUID().uuidString // Fallback in case of failure
        }
    }
    
    private func saveDeviceId(id: String) -> Bool {
        let account = "deviceID"
        guard let data = id.data(using: .utf8) else { return false }
        return save(service: service, account: account, data: data)
    }
    
    private func readDeviceId() -> String? {
        let account = "deviceID"
        guard let data = read(service: service, account: account) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Generic Keychain Methods
    
    /// Keychain에 데이터 저장
    private func save(service: String, account: String, data: Data) -> Bool {
        // 기존 항목 삭제
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        
        // 새 항목 추가
        let attributes = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ] as [String : Any]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Keychain에서 데이터 불러오기
    private func read(service: String, account: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }
    
    /// Keychain에서 데이터 삭제
    private func delete(service: String, account: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ] as [String : Any]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

