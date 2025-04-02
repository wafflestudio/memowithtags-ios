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
    
    //MARK: - 로그인
    func login(email: String, password: String) async throws -> AuthDto {
        print("🙏 login")
        let response = await AF.request(AuthRouter.login(email: email, password: password))
            .serializingDecodable(AuthDto.self)
            .response
        let dto = try handleErrorDecodable(response: response)
        return dto
    }
    
    //MARK: - 인증코드 전송
    func sendEmail(email: String, type: EmailType) async throws {
        print("🙏 send email")
        let response = await AF.request(AuthRouter.sendEmail(email: email, type: type))
            .validate(statusCode: 200..<300)
            .serializingData()
            .response
        try handleError(response: response)
    }
    
    //MARK: - 인증코드 검증
    func verifyEmail(email: String, code: String, type: EmailType) async throws {
        print("🙏 verify email")
        let response = await AF.request(AuthRouter.verifyEmail(email: email, code: code, type: type))
            .validate(statusCode: 200..<300)
            .serializingData()
            .response
        try handleError(response: response)
    }
    
    //MARK: - 회원가입
    func register(nickname: String, email: String, password: String) async throws -> AuthDto {
        print("🙏 register")
        let response = await AF.request(AuthRouter.register(nickname: nickname, email: email, password: password))
            .serializingDecodable(AuthDto.self)
            .response
        let dto = try handleErrorDecodable(response: response)
        return dto
    }
    
    //MARK: - 비밀번호 재설정
    func resetPassword(email: String, newPassword: String) async throws {
        print("🙏 reset password")
        let response = await AF.request(AuthRouter.resetPassword(email: email, newPassword: newPassword))
            .validate(statusCode: 200..<300)
            .serializingData()
            .response
        try handleError(response: response)
    }
    
    //MARK: - 유저 정보 가져오기
    func getUserInfo() async throws -> UserDto {
        print("🙏 get user info")
        let response = await AF.request(AuthRouter.getUserInfo, interceptor: tokenInterceptor)
            .serializingDecodable(UserDto.self)
            .response
        let dto = try handleErrorDecodable(response: response)
        return dto
    }
    
    //MARK: - 닉네임 변경
    func changeNickname(nickname: String) async throws {
        print("🙏 change nickname")
        let response = await AF.request(AuthRouter.changeNickname(nickname: nickname), interceptor: tokenInterceptor)
            .serializingDecodable(UserDto.self)
            .response
        let _ = try handleErrorDecodable(response: response)
    }
    
    //MARK: - 패스워드 변경
    func changePassword(currentPassword: String, newPassword: String) async throws {
        print("🙏 change password")
        let response = await AF.request(AuthRouter.changePassword(currentPassword: currentPassword, newPassword: newPassword), interceptor: tokenInterceptor)
            .serializingDecodable(UserDto.self)
            .response
        let _ = try handleErrorDecodable(response: response)
    }
    
    //MARK: - 회원탈퇴
    func withdrawal(email: String) async throws {
        print("🙏 withdrawal")
        let response = await AF.request(AuthRouter.withdrawal(email: email), interceptor: tokenInterceptor)
            .validate(statusCode: 200..<300)
            .serializingData()
            .response
        try handleError(response: response)
    }
    
    //MARK: - 카카오 로그인
    func kakaoLogin(authCode: String) async throws -> SocialAuthDto {
        print("🙏 kakao login")
        let response = await AF.request(AuthRouter.kakaoLogin(authCode: authCode))
            .serializingDecodable(SocialAuthDto.self)
            .response
        let dto = try handleErrorDecodable(response: response)
        return dto
    }
    
    //MARK: - 네이버 로그인
    func naverLogin(authCode: String) async throws -> SocialAuthDto {
        print("🙏 naver login")
        let response = await AF.request(AuthRouter.naverLogin(authCode: authCode))
            .serializingDecodable(SocialAuthDto.self)
            .response
        let dto = try handleErrorDecodable(response: response)
        return dto
    }
    
    //MARK: - 구글 로그인
    func googleLogin(authCode: String) async throws -> SocialAuthDto {
        print("🙏 google login")
        let response = await AF.request(AuthRouter.googleLogin(authCode: authCode))
            .serializingDecodable(SocialAuthDto.self)
            .response
        let dto = try handleErrorDecodable(response: response)
        return dto
    }
}

