//
//  UserService.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/22/25.
//

import Foundation
import Factory

protocol UserService {
    func getUser() async -> Result<User, GetUserError>
    func changeNickname(nickname: String) async -> Result<Void, ChangeNicknameError>
    func changePassword(currentPassword: String, newPassword: String) async -> Result<Void, ChangePasswordError>
    func withdrawal(email: String) async -> Result<Void, WithdrawalError>
}

final class DefaultUserService: UserService {
    @Injected(\.authRepository) private var authRepository: AuthRepository

    //MARK: - 유저 정보 가져오기
    func getUser() async -> Result<User, GetUserError> {
        do {
            let dto = try await authRepository.getUserInfo()
            let user = dto.toUser()
            return .success(user)
        } catch {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 닉네임 변경
    func changeNickname(nickname: String) async -> Result<Void, ChangeNicknameError> {
        do {
            try await authRepository.changeNickname(nickname: nickname)
            return .success(())
        } catch {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 비밀번호 변경
    func changePassword(currentPassword: String, newPassword: String) async -> Result<Void, ChangePasswordError> {
        do {
            try await authRepository.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            return .success(())
        } catch {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 회원 탙퇴
    func withdrawal(email: String) async -> Result<Void, WithdrawalError> {
        do {
            try await authRepository.withdrawal(email: email)
            _ = KeyChainManager.shared.deleteAccessToken()
            _ = KeyChainManager.shared.deleteRefreshToken()
    
            return .success(())
        } catch {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
}

extension Container {
    var userService: Factory<UserService> {
        self { DefaultUserService() }.singleton
    }
}
