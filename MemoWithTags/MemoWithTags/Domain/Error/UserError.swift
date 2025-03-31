//
//  UserError.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/23/25.
//

import Foundation

//MARK: - 유저 정보 가져오기 에러
enum GetUserError: CustomError {
    case userNotFound
    case networkError
    case unknown
    
    var type: ErrorType {
        switch self {
        case .userNotFound:
            return .relogin
        default:
            return .normal
        }
    }
    
    static func from(baseError: BaseError) -> GetUserError {
        switch baseError.code {
        case .USER_AUTHENTICATION_FAILED: return .userNotFound
        case .CONNECT_FAILED: return .networkError
        default: return .unknown
        }
    }
}

extension GetUserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotFound: return "사용자를 찾을 수 없습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
}
 

//MARK: - 닉네임 변경 에러
enum ChangeNicknameError: CustomError {
    case userNotFound
    case networkError
    case unknown
    
    var type: ErrorType {
        switch self {
        case .userNotFound:
            return .relogin
        default:
            return .normal
        }
    }
    
    static func from(baseError: BaseError) -> ChangeNicknameError {
        switch baseError.code {
        case .USER_AUTHENTICATION_FAILED: return .userNotFound
        case .CONNECT_FAILED: return .networkError
        default: return .unknown
        }
    }
}

extension ChangeNicknameError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotFound: return "사용자를 찾을 수 없습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
}

//MARK: - 비밀번호 변경 에러
enum ChangePasswordError: CustomError {
    case userNotFound
    case notMatchCurrentPassword
    case networkError
    case unknown
    case invalidPassword
    case passwordNotMatch
    
    var type: ErrorType {
        switch self {
        case .userNotFound:
            return .relogin
        default:
            return .normal
        }
    }
    
    static func from(baseError: BaseError) -> ChangePasswordError {
        switch baseError.code {
        case .USER_AUTHENTICATION_FAILED: return .userNotFound
        case .USER_UPDATE_PASSWORD_INVALID: return .notMatchCurrentPassword
        case .CONNECT_FAILED: return .networkError
        default: return .unknown
        }
    }
}

extension ChangePasswordError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotFound: return "비밀번호 변경을 실패했습니다."
        case .notMatchCurrentPassword: return "기존 비밀번호가 일치하지 않습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .invalidPassword: return "새 비밀번호 형식이 잘못되었습니다."
        case .passwordNotMatch: return "새 비밀번호가 일치하지 않습니다."
        }
    }
}

//MARK: - 회원 탈퇴 에러
enum WithdrawalError: CustomError {
    case userNotFound
    case emailNotMatch
    case networkError
    case unknown
    
    var type: ErrorType {
        switch self {
        case .userNotFound:
            return .relogin
        default:
            return .normal
        }
    }
    
    static func from(baseError: BaseError) -> WithdrawalError {
        switch baseError.code {
        case .USER_AUTHENTICATION_FAILED: return .userNotFound
        case .USER_EMAIL_NOT_MATCHED: return .emailNotMatch
        case .CONNECT_FAILED: return .networkError
        default: return .unknown
        }
    }
}

extension WithdrawalError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotFound: return "사용자를 찾을 수 없습니다."
        case .emailNotMatch: return "이메일이 올바르지 않습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
}
