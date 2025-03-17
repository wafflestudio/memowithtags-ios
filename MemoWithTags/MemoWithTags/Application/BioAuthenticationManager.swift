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
        // 커스텀 Cancel 버튼 텍스트 설정 (예: 대체 인증 방식 안내)
        context.localizedCancelTitle = "기기 암호 입력하기"
        
        var authError: NSError?
        
        // deviceOwnerAuthentication 정책 사용: biometrics 실패 시 암호 입력으로 대체 가능
        let policy: LAPolicy = .deviceOwnerAuthentication
        
        // 인증 가능 여부 확인
        guard context.canEvaluatePolicy(policy, error: &authError) else {
            print("FaceID 및 기기 암호 사용 불가: \(authError?.localizedDescription ?? "알 수 없는 에러")")
            // fallback: 예를 들어, 사용자 이름과 비밀번호를 입력받는 등의 대체 인증 로직 실행
            return false
        }
        
        do {
            // 인증 시도 (비동기/async-await 방식)
            try await context.evaluatePolicy(policy, localizedReason: reason)
            // 인증 성공
            return true
        } catch {
            print("인증 실패: \(error.localizedDescription)")
            // fallback: 인증 실패 시 대체 인증 로직 실행
            return false
        }
    }
}
