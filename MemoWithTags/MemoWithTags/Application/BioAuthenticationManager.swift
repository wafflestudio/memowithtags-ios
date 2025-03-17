//
//  AuthenticationManager.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/17/25.
//

import LocalAuthentication

final class BioAuthenticationManager {
    /// Singleton 인스턴스
    static let shared = BioAuthenticationManager()
    private init() {}
    
    /// 생체 인증 또는 기기 암호를 사용하여 사용자를 인증합니다.
    /// - Parameter reason: 인증 요청 시 사용자에게 보여줄 메시지
    /// - Returns: 인증 성공 시 true, 실패 또는 인증 불가 시 false
    func authenticateUser(reason: String) async -> Bool {
        let context = LAContext()
        // 커스텀 Cancel 버튼 텍스트 설정
        context.localizedCancelTitle = "기기 암호 입력하기"
        
        var authError: NSError?
        
        let policy: LAPolicy = .deviceOwnerAuthentication
        
        // 인증 가능 여부 확인
        guard context.canEvaluatePolicy(policy, error: &authError) else {
            print("FaceID 및 기기 암호 사용 불가: \(authError?.localizedDescription ?? "알 수 없는 에러")")
            return false
        }
        
        do {
            try await context.evaluatePolicy(policy, localizedReason: reason)
            print("인증 성공")
            return true
        } catch {
            print("인증 실패: \(error.localizedDescription)")
            return false
        }
    }
}
