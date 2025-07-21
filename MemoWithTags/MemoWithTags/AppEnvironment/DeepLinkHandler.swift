////
////  DeepLinkHandler.swift
////  MemoWithTags
////
////  Created by 최진모 on 1/22/25.
////
//
//import Foundation
//
//@MainActor
//struct DeepLinkHandler {
//    let appState: AppState
//    let socialLoginService: SocialLoginService
//    
//    func handle(url: URL) async {
//        guard url.scheme == "memowithtags",
//              url.host == "oauth",
//              let service = url.pathComponents.last,
//              let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "code" })?.value
//        else {
//            appState.system.alert(error: SocialLoginError.invalidAccess)
//            return
//        }
//        
//        do {
//            switch service {
//            case "kakao":
//                let result = await socialLoginService.kakaoLogin(authCode: code)
//                
//                switch result {
//                case .success(let auth):
//                    appState.user.isLoggedIn = true
//                    
//                    if auth.isNewUser {
//                        appState.navigation.push(to: .nicknameSetting)
//                    } else {
//                        appState.navigation.push(to: .main)
//                    }
//
//                case .failure(let error):
//                    appState.system.alert(error: error)
//                }
//                
//            case "google":
//                let result = await socialLoginService.googleLogin(authCode: code)
//                
//                switch result {
//                case .success(let auth):
//                    appState.user.isLoggedIn = true
//                    
//                    if auth.isNewUser {
//                        appState.navigation.push(to: .nicknameSetting)
//                    } else {
//                        appState.navigation.push(to: .main)
//                    }
//                    
//                case .failure(let error):
//                    appState.system.alert(error: error)
//                }
//                
//            case "naver":
//                let result = await socialLoginService.naverLogin(authCode: code)
//                
//                switch result {
//                case .success(let auth):
//                    appState.user.isLoggedIn = true
//                    
//                    if auth.isNewUser {
//                        appState.navigation.push(to: .nicknameSetting)
//                    } else {
//                        appState.navigation.push(to: .main)
//                    }
//                    
//                case .failure(let error):
//                    appState.system.alert(error: error)
//                }
//                
//            default:
//                appState.system.alert(error: SocialLoginError.invalidAccess)
//            }
//        }
//    }
//}
