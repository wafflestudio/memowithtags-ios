//
//  AuthenticationManager.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/17/25.
//

import LocalAuthentication

final class BioAuthenticationManager {
    ///singleton
    static let shared = BioAuthenticationManager()
    private init() {}
    
    // 생체 인증 또는 디바이스 비밀번호를 사용하여 사용자를 인증합니다.
    // 인증에 성공하면 true, 실패하면 false 반환
    func authenticateUser(reason: String) async -> Bool {
        let context = LAContext()
        var authError: NSError?
        
        // 인증 정책 설정: Face ID 사용
        let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        
        // 인증 가능 여부 확인
        if context.canEvaluatePolicy(policy, error: &authError) {
            do {
                // 인증 시도
                let success = try await context.evaluatePolicyAsync(policy, localizedReason: reason)
                return success
            } catch {
                // 인증 실패 또는 에러 발생
                print("Face ID authentication failed with error: \(error.localizedDescription)")
                return false
            }
        } else {
            print("Face ID not available. Switch to Device Passcode.")
            
            // 인증 정책 설정: 디바이스 비밀번호 사용
            let policy: LAPolicy = .deviceOwnerAuthentication
            
            // 인증 가능 여부 확인
            if context.canEvaluatePolicy(policy, error: &authError) {
                do {
                    // 인증 시도
                    let success = try await context.evaluatePolicyAsync(policy, localizedReason: reason)
                    return success
                } catch {
                    // 인증 실패 또는 에러 발생
                    print("Device Passcode authentication failed with error: \(error.localizedDescription)")
                    return false
                }
            } else {
                // 인증을 사용할 수 없음
                print("Authentication not available.")
                return false
            }
        }
    }
}

extension LAContext {
    /// An async wrapper for `evaluatePolicy(_:localizedReason:)` using Swift concurrency.
    /// - Parameters:
    ///   - policy: The policy to evaluate.
    ///   - localizedReason: The reason for requesting authentication.
    /// - Returns: `true` if authentication succeeds.
    func evaluatePolicyAsync(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            evaluatePolicy(policy, localizedReason: localizedReason) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
}
