//
//  DefaultAuthRepository.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation
import Alamofire

final class DefaultAuthRepository: AuthRepository {
    
    let tokenInterceptor = TokenInterceptor()
    
    func register(nickname: String, email: String, password: String) async throws {
        print("register")
        let response = await AF.request(AuthRouter.register(nickname: nickname, email: email, password: password)).serializingData().response
        try handleError(response: response)
    }
    
    func login(email: String, password: String) async throws -> AuthDto {
        print("login")
        let response = await AF.request(AuthRouter.login(email: email, password: password)).serializingDecodable(AuthDto.self).response
        let dto = try handleErrorDecodable(response: response)
        print("accessToken: \(dto.accessToken)")
        return dto
    }
    
    func verifyEmail(email: String, code: String) async throws {
        print("verify email")
        let response = await AF.request(AuthRouter.verifyEmail(email: email, code: code)).serializingData().response
        try handleError(response: response)
    }
    
    func forgotPassword(email: String) async throws {
        print("forgot password")
        let response = await AF.request(AuthRouter.forgotPassword(email: email)).serializingData().response
        try handleError(response: response)
    }
    
    func resetPassword(email:String, code: String, newPassword: String) async throws {
        print("reset password")
        let response = await AF.request(AuthRouter.resetPassword(email: email, code: code, newPassword: newPassword)).serializingData().response
        try handleError(response: response)
    }
    
    func getUserInfo() async throws -> UserDto {
        print("get user info")
        let response = await AF
            .request(AuthRouter.getUserInfo, interceptor: tokenInterceptor).serializingDecodable(UserDto.self).response
        let dto = try handleErrorDecodable(response: response)
        
        return dto
    }
    
    func setProfile(nickname: String) async throws {
        print("set profile")
        let response = await AF
            .request(AuthRouter.setProfile(nickname: nickname), interceptor: tokenInterceptor).serializingDecodable(UserDto.self).response
        let _ = try handleErrorDecodable(response: response)
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        print("change password")
        let response = await AF
            .request(AuthRouter.changePassword(currentPassword: currentPassword, newPassword: newPassword), interceptor: tokenInterceptor).serializingDecodable(UserDto.self).response
        let _ = try handleErrorDecodable(response: response)
    }
    
    func kakaoLogin(authCode: String) async throws -> SocialAuthDto {
        print("kakao login")
        let response = await AF.request(AuthRouter.kakaoLogin(authCode: authCode)).serializingDecodable(SocialAuthDto.self).response
        let dto = try handleErrorDecodable(response: response)
        print("accessToken: \(dto.accessToken)")
        return dto
    }
    
    func naverLogin(authCode: String) async throws -> SocialAuthDto {
        print("naver login")
        let response = await AF.request(AuthRouter.naverLogin(authCode: authCode)).serializingDecodable(SocialAuthDto.self).response
        let dto = try handleErrorDecodable(response: response)
        print("accessToken: \(dto.accessToken)")
        return dto
    }
    
    func googleLogin(authCode: String) async throws -> SocialAuthDto {
        print("google login")
        let response = await AF.request(AuthRouter.googleLogin(authCode: authCode)).serializingDecodable(SocialAuthDto.self).response
        let dto = try handleErrorDecodable(response: response)
        print("accessToken: \(dto.accessToken)")
        return dto
    }
    
    func withdrawal(email: String) async throws {
        print("withdrawal")
        let response = await AF.request(AuthRouter.withdrawal(email: email), interceptor: tokenInterceptor).serializingData().response
        try handleError(response: response)
    }
}
