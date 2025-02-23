//
//  DeepLinkHandler.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/22/25.
//

import Foundation

@MainActor
struct DeepLinkHandler {
    let appState: AppState
    let socialLoginService: SocialLoginService
    
    func handle(url: URL) async {
        // 유효한 URL인지 확인
        guard url.scheme == "memowithtags",
              url.host == "oauth",
              let service = url.pathComponents.last,
              let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                                .queryItems?
                                .first(where: { $0.name == "code" })?
                                .value
        else {
            appState.system.showAlert = true
            appState.system.errorMessage = "유효하지 않은 접근"
            return
        }
        
        // 소셜 로그인 분기 처리
        switch service {
        case "kakao":
            let result = await socialLoginService.kakaoLogin(authCode: code)
            switch result {
            case .success(let auth):
                handleLoginSuccess(auth: auth)
            case .failure(let error):
                handleLoginFailure(error: error)
            }
            
        case "google":
            let result = await socialLoginService.googleLogin(authCode: code)
            switch result {
            case .success(let auth):
                handleLoginSuccess(auth: auth)
            case .failure(let error):
                handleLoginFailure(error: error)
            }
            
        case "naver":
            let result = await socialLoginService.naverLogin(authCode: code)
            switch result {
            case .success(let auth):
                handleLoginSuccess(auth: auth)
            case .failure(let error):
                handleLoginFailure(error: error)
            }
            
        default:
            appState.system.showAlert = true
            appState.system.errorMessage = "유효하지 않은 접근"
        }
    }
    
    // 로그인 성공 시 로직 분리
    private func handleLoginSuccess(auth: SocialAuth) {
        appState.user.isLoggedIn = true
        
        // 새 유저 여부에 따라 다음 화면 이동
        if auth.isNewUser {
            appState.navigation.push(to: .nicknameSetting)
        } else {
            appState.navigation.push(to: .main)
        }
    }
    
    // 로그인 실패 시 로직 분리
    private func handleLoginFailure(error: SocialLoginError) {
        appState.system.showAlert = true
        appState.system.errorMessage = error.localizedDescription
    }
}

