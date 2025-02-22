//
//  UserRepository.swift
//  MemoWithTags
//
//  Created by 최진모 on 12/29/24.
//

import Foundation

protocol AuthRepository: BaseRepository {
    ///로그인하는 함수. email과 password를 받아 계정 토큰을 반환함
    func login(email: String, password: String) async throws -> AuthDto
    ///인증 메일 보내는 함수
    func sendEmail(email: String) async throws
    ///이메일 인증하는 함수
    func verifyEmail(email: String, code: String) async throws
    ///회원가입하는 함수.
    func register(nickname: String, email: String, password: String) async throws -> AuthDto
    ///비밀번호 재설정하는 함수
    func resetPassword(email: String, newPassword: String) async throws
    ///유저 정보 가져오는 함수
    func getUserInfo() async throws -> UserDto
    ///닉네임 수정하는 함수
    func changeNickname(nickname: String) async throws
    ///비밀번호 수정하는 함수
    func changePassword(currentPassword: String, newPassword: String) async throws
    ///회원탈퇴하는 함수
    func withdrawal(email: String) async throws
    ///카카오 로그인 하는 함수
    func kakaoLogin(authCode: String) async throws -> SocialAuthDto
    ///네이버 로그인 하는 함수
    func naverLogin(authCode: String) async throws -> SocialAuthDto
    ///구글 로그인 하는 함수
    func googleLogin(authCode: String) async throws -> SocialAuthDto
}

