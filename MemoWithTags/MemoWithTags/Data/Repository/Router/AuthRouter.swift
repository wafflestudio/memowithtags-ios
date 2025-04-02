//
//  AuthRouter.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.

import Foundation
import Alamofire

enum EmailType: String {
    case Register = "Register"
    case ResetPassword = "ResetPassword"
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
        return URL(string: NetworkConfiguration.baseURL)!
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
            return "/auth/login"
        case .sendEmail:
            return "/mail"
        case .verifyEmail:
            return "/mail/verify"
        case .register:
            return "/auth/register"
        case .resetPassword:
            return "/auth/reset-password"
        case .refreshToken:
            return "/auth/refresh-token"
        case .getUserInfo:
            return "/auth/me"
        case .changeNickname:
            return "/auth/nickname"
        case .changePassword:
            return "/auth/password"
        case .withdrawal:
            return "/auth/withdrawal"
        case .kakaoLogin:
            return "/auth/login/kakao"
        case .googleLogin:
            return "/auth/login/google"
        case .naverLogin:
            return "/auth/login/naver"
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
    
    // Custom URLRequest 생성: sendEmail, verifyEmail는 URL에 "type" 쿼리 파라미터를 추가합니다.
    func asURLRequest() throws -> URLRequest {
        // 기본 URL 생성 (예: https://memowithtags.kro.kr/api/v1/mail)
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        switch self {
        case let .sendEmail(_, type):
            // URL에 query parameter "type" 추가
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                var queryItems = urlComponents.queryItems ?? []
                queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
                urlComponents.queryItems = queryItems
                if let newURL = urlComponents.url {
                    request.url = newURL
                }
            }
            // 나머지 파라미터는 body에 JSON 인코딩
            if let params = parameters {
                request = try JSONEncoding.default.encode(request, with: params)
            }
            
        case let .verifyEmail(_, _, type):
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                var queryItems = urlComponents.queryItems ?? []
                queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
                urlComponents.queryItems = queryItems
                if let newURL = urlComponents.url {
                    request.url = newURL
                }
            }
            if let params = parameters {
                request = try JSONEncoding.default.encode(request, with: params)
            }
            
        default:
            // 다른 케이스는 기본 인코딩 방식을 사용 (GET이면 URLEncoding, 그 외는 JSONEncoding)
            switch method {
            case .get:
                if let params = parameters {
                    request = try URLEncoding.default.encode(request, with: params)
                }
            default:
                if let params = parameters {
                    request = try JSONEncoding.default.encode(request, with: params)
                }
            }
        }
        
        print("👉 url: \(request.url?.absoluteString ?? "No URL")")
        return request
    }
}
