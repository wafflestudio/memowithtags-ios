//
//  AuthRouter.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import Foundation
import Alamofire

enum AuthRouter: Router {
    case register(nickname: String, email: String, password: String)
    case login(email: String, password: String)
    case forgotPassword(email: String)
    case resetPassword(email: String, code: String, newPassword: String)
    case verifyEmail(email: String, code: String)
    case refreshToken(token: String)
    case getUserInfo
    case setProfile(nickname: String)
    case changePassword(currentPassword: String, newPassword: String)
    case kakaoLogin(authCode: String)
    case naverLogin(authCode: String)
    case googleLogin(authCode: String)
    case withdrawal(email: String)
    
    var baseURL: URL {
        return URL(string: NetworkConfiguration.baseURL + "/auth")!
    }
    
    var method: HTTPMethod {
        switch self {
        case .register, .login, .forgotPassword, .resetPassword, .verifyEmail, .refreshToken:
            return .post
        case .getUserInfo, .kakaoLogin, .naverLogin, .googleLogin:
            return .get
        case .changePassword, .setProfile:
            return .put
        case .withdrawal:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return "/register"
        case .login:
            return "/login"
        case .forgotPassword:
            return "/forgot-password"
        case .resetPassword:
            return "/reset-password"
        case .verifyEmail:
            return "/verify-email"
        case .refreshToken:
            return "/refresh-token"
        case .getUserInfo:
            return "/me"
        case .setProfile:
            return "/nickname"
        case .changePassword:
            return "/password"
        case .kakaoLogin:
            return "/login/kakao"
        case .googleLogin:
            return "/login/google"
        case .naverLogin:
            return "/login/naver"
        case .withdrawal:
            return "/withdrawal"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .register(nickname, email, password):
            return ["nickname": nickname, "email": email, "password": password]
        case let .login(email, password):
            return ["email": email, "password": password]
        case let .verifyEmail(email, code):
            return ["email": email, "verificationCode": code]
        case let .forgotPassword(email):
            return ["email": email]
        case let .resetPassword(email, code, newPassword):
            return ["email": email, "verificationCode": code, "password": newPassword]
        case let .refreshToken(token):
            return ["refreshToken": token]
        case .getUserInfo:
            return nil
        case let .kakaoLogin(code), let .googleLogin(code), let .naverLogin(code):
            return ["code": code]
        case let .setProfile(nickname):
            return ["nickname": nickname]
        case let .changePassword(currentPassword, newPassword):
            return ["originalPassword": currentPassword, "newPassword": newPassword]
        case let .withdrawal(email):
            return ["email": email]
        }
    }
}
