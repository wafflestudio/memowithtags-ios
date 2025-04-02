//
//  AuthRouter.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import Foundation
import Alamofire

enum EmailType: String {
    case Register
    case ResetPassword
}

enum AuthRouter: Router {
    case login(email: String, password: String)
    case sendEmail(email: String, type: EmailType)
    case verifyEmail(email: String, code: String, type: EmailType)
    case register(nickname: String, email: String, password: String)
    case resetPassword(email: String, newPassword: String)
    
    case refreshToken(token: String)
    
    case getUserInfo
    case changeNickname(nickname: String)
    case changePassword(currentPassword: String, newPassword: String)
    case withdrawal(email: String)
    
    case kakaoLogin(authCode: String)
    case naverLogin(authCode: String)
    case googleLogin(authCode: String)
    
    var baseURL: URL {
        return URL(string: NetworkConfiguration.baseURL + "/auth")!
    }
    
    var method: HTTPMethod {
        switch self {
        case .register, .login, .resetPassword, .sendEmail, .verifyEmail, .refreshToken:
            return .post
        case .getUserInfo, .kakaoLogin, .naverLogin, .googleLogin:
            return .get
        case .changePassword, .changeNickname:
            return .put
        case .withdrawal:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case let .sendEmail(_, type):
            return "/mail?type=\(type.rawValue)"
        case let .verifyEmail(_, _, type):
            return "/mail/verify?type=\(type.rawValue)"
        case .register:
            return "/register"
        case .resetPassword:
            return "/reset-password"
        case .refreshToken:
            return "/refresh-token"
        case .getUserInfo:
            return "/me"
        case .changeNickname:
            return "/nickname"
        case .changePassword:
            return "/password"
        case .withdrawal:
            return "/withdrawal"
            
        case .kakaoLogin:
            return "/login/kakao"
        case .googleLogin:
            return "/login/google"
        case .naverLogin:
            return "/login/naver"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .login(email, password):
            return ["email": email, "password": password]
        case let .sendEmail(email, _):
            return ["email": email]
        case let .verifyEmail(email, code, _):
            return ["email": email, "verificationCode": code]
        case let .register(nickname, email, password):
            return ["nickname": nickname, "email": email, "password": password]
        case let .resetPassword(email, newPassword):
            return ["email": email, "password": newPassword]
        case let .refreshToken(token):
            return ["refreshToken": token]
        case .getUserInfo:
            return nil
        case let .changeNickname(nickname):
            return ["nickname": nickname]
        case let .changePassword(currentPassword, newPassword):
            return ["originalPassword": currentPassword, "newPassword": newPassword]
        case let .withdrawal(email):
            return ["email": email]
            
        case let .kakaoLogin(code), let .googleLogin(code), let .naverLogin(code):
            return ["code": code]
        }
    }
}

