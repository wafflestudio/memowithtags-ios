//
//  SocialAuthService.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/22/25.
//

import Foundation
import Factory

protocol SocialLoginService {
    func kakaoLogin(authCode: String) async -> Result<SocialAuth, SocialLoginError>
    func naverLogin(authCode: String) async -> Result<SocialAuth, SocialLoginError>
    func googleLogin(authCode: String) async -> Result<SocialAuth, SocialLoginError>
}

final class DefaultSocialLoginService: SocialLoginService {
    @Injected(\.authRepository) private var authRepository: AuthRepository
    
    //MARK: - 카카오 로그인
    func kakaoLogin(authCode: String) async -> Result<SocialAuth, SocialLoginError> {
        do {
            let dto = try await authRepository.kakaoLogin(authCode: authCode)
            let auth = dto.toAuth()
            
            let isAccessSaved = KeyChainManager.shared.saveAccessToken(token: auth.accessToken)
            let isRefreshSaved = KeyChainManager.shared.saveRefreshToken(token: auth.refreshToken)
            
            if isAccessSaved && isRefreshSaved {
                return .success(auth)
            } else {
                return .failure(.tokenSaveError)
            }
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 네이버 로그인
    func naverLogin(authCode: String) async -> Result<SocialAuth, SocialLoginError> {
        do {
            let dto = try await authRepository.naverLogin(authCode: authCode)
            let auth = dto.toAuth()
            
            let isAccessSaved = KeyChainManager.shared.saveAccessToken(token: auth.accessToken)
            let isRefreshSaved = KeyChainManager.shared.saveRefreshToken(token: auth.refreshToken)
            
            if isAccessSaved && isRefreshSaved {
                return .success(auth)
            } else {
                return .failure(.tokenSaveError)
            }
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 구글 로그인
    func googleLogin(authCode: String) async -> Result<SocialAuth, SocialLoginError> {
        do {
            let dto = try await authRepository.googleLogin(authCode: authCode)
            let auth = dto.toAuth()
            
            let isAccessSaved = KeyChainManager.shared.saveAccessToken(token: auth.accessToken)
            let isRefreshSaved = KeyChainManager.shared.saveRefreshToken(token: auth.refreshToken)
            
            if isAccessSaved && isRefreshSaved {
                return .success(auth)
            } else {
                return .failure(.tokenSaveError)
            }
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
}
