//
//  AuthService.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/22/25.
//

import Foundation

protocol AuthService {
    ///로그인
    func login(email: String, password: String) async -> Result<Void, LoginError>
    ///로그아웃
    func logout() async -> Result<Void, LogoutError>
    ///인증코드 전송
    func sendCode(email: String) async -> Result<Void, SendCodeError>
    ///인증코드 검증
    func verifyCode(email: String, code: String) async -> Result<Void, VerifyCodeError>
    ///회원가입
    func register(email: String, passsword: String, nickname: String) async -> Result<Void, RegisterError>
    ///비밀번호 재설정
    func resetPassword(email: String, newPassword: String) async -> Result<Void, ResetPasswordError>
}

final class DefaultAuthService: AuthService {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    //MARK: - 로그인
    func login(email: String, password: String) async -> Result<Void, LoginError> {
        do {
            let dto = try await authRepository.login(email: email, password: password)
            let auth = dto.toAuth()
            
            let isAccessSaved = KeyChainManager.shared.saveAccessToken(token: auth.accessToken)
            let isRefreshSaved = KeyChainManager.shared.saveRefreshToken(token: auth.refreshToken)
            
            if isAccessSaved && isRefreshSaved {
                return .success(())
            } else {
                return .failure(.tokenSaveError)
            }
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 로그아웃
    func logout() async -> Result<Void, LogoutError> {
        let isAccessDeleted = KeyChainManager.shared.deleteAccessToken()
        let isRefreshDeleted = KeyChainManager.shared.deleteRefreshToken()
        
        if isAccessDeleted && isRefreshDeleted {
            return .success(())
        } else {
            return .failure(.tokenDeleteError)
        }
    }
    
    //MARK: - 인증코드 전송
    func sendCode(email: String) async -> Result<Void, SendCodeError> {
        <#code#>
    }
    
    //MARK: - 인증코드 검증
    func verifyCode(email: String, code: String) async -> Result<Void, VerifyCodeError> {
        <#code#>
    }
    
    //MARK: - 회원가입
    func register(email: String, passsword: String, nickname: String) async -> Result<Void, RegisterError> {
        <#code#>
    }
    
    //MARK: - 비밀번호 재설정
    func resetPassword(email: String, newPassword: String) async -> Result<Void, ResetPasswordError> {
        <#code#>
    }
}
