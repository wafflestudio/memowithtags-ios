//
//  Error.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/2/25.
//

import Foundation

enum LoginError: Error {
    case invalidCredentials
    case networkError
    case unknown
    case tokenSaveError
    case invalidEmail
    
    func localizedDescription() -> String {
        switch self {
        case .invalidCredentials: return "이메일 또는 비밀번호가 잘못되었습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .tokenSaveError: return "인증 토큰을 저장하는 중 오류가 발생했습니다."
        case .invalidEmail: return "이메일 형식이 잘못되었습니다."
        }
    }
    
    static func from(baseError: BaseError) -> LoginError {
        switch baseError {
        case .UNAUTHORIZED: return .invalidCredentials
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum LogoutError: Error {
    case tokenDeleteError
    
    func localizedDescription() -> String {
        switch self {
        case .tokenDeleteError: return "로그아웃 처리 중 오류가 발생했습니다."
        }
    }
}

enum RegisterError: Error {
    case emailAlreadyExists
    case networkError
    case unknown
    case invalidEmail
    case invalidPassword
    case passwordNotMatch
    
    func localizedDescription() -> String {
        switch self {
        case .emailAlreadyExists: return "이미 등록된 이메일입니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .invalidEmail: return "이메일 형식이 잘못되었습니다."
        case .invalidPassword: return "비밀번호 형식이 잘못되었습니다."
        case .passwordNotMatch: return "비밀번호가 일치하지 않습니다."
        }
    }
    
    static func from(baseError: BaseError) -> RegisterError {
        switch baseError {
        case .BAD_REQUEST: return .emailAlreadyExists
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum ForgotPasswordError: Error {
    case userNotFound
    case networkError
    case unknown
    case invalidEmail
    
    func localizedDescription() -> String {
        switch self {
        case .userNotFound: return "사용자를 찾을 수 없습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .invalidEmail: return "이메일 형식이 잘못되었습니다."
        }
    }
    
    static func from(baseError: BaseError) -> ForgotPasswordError {
        switch baseError {
        case .UNAUTHORIZED: return .userNotFound
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum ResetPasswordError: Error {
    case notMatchCode
    case networkError
    case unknown
    case invalidPassword
    case passwordNotMatch
    
    func localizedDescription() -> String {
        switch self {
        case .notMatchCode: return "인증코드가 올바르지 않습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .invalidPassword: return "비밀번호 형식이 잘못되었습니다."
        case .passwordNotMatch: return "비밀번호가 일치하지 않습니다."
        }
    }
    
    static func from(baseError: BaseError) -> ResetPasswordError {
        switch baseError {
        case .UNAUTHORIZED: return .notMatchCode
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum VerifyEmailError: Error {
    case notMatchCode
    case networkError
    case unknown
    case tokenSaveError
    
    func localizedDescription() -> String {
        switch self {
        case .notMatchCode: return "인증코드가 올바르지 않습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .tokenSaveError: return "인증 토큰을 저장하는 중 오류가 발생했습니다."
        }
    }
    
    static func from(baseError: BaseError) -> VerifyEmailError {
        switch baseError {
        case .UNAUTHORIZED: return .notMatchCode
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum GetUserInfoError: Error {
    case userNotFound
    case networkError
    case unknown
    
    func localizedDescription() -> String {
        switch self {
        case .userNotFound: return "사용자를 찾을 수 없습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    static func from(baseError: BaseError) -> GetUserInfoError {
        switch baseError {
        case .UNAUTHORIZED: return .userNotFound
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum SetProfileError: Error {
    case userNotFound
    case networkError
    case unknown
    
    func localizedDescription() -> String {
        switch self {
        case .userNotFound: return "프로필을 업데이트하는 데 실패했습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    static func from(baseError: BaseError) -> SetProfileError {
        switch baseError {
        case .UNAUTHORIZED: return .userNotFound
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum ChangePasswordError: Error {
    case userNotFound
    case notMatchCurrentPassword
    case networkError
    case unknown
    case invalidPassword
    case passwordNotMatch
    
    func localizedDescription() -> String {
        switch self {
        case .userNotFound: return "비밀번호를 변경하는 데 실패했습니다."
        case .notMatchCurrentPassword: return "기존 비밀번호가 일치하지 않습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .invalidPassword: return "새 비밀번호 형식이 잘못되었습니다."
        case .passwordNotMatch: return "새 비밀번호가 일치하지 않습니다."
        }
    }
    
    static func from(baseError: BaseError) -> ChangePasswordError {
        switch baseError {
        case .UNAUTHORIZED: return .userNotFound
        case .FORBIDDEN: return .notMatchCurrentPassword
        case .BAD_REQUEST: return .notMatchCurrentPassword
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum SocialLoginError: Error {
    case invalidCode
    case emailAlreadyExists
    case networkError
    case unknown
    case tokenSaveError
    
    func localizedDescription() -> String {
        switch self {
        case .invalidCode: return "소셜 로그인 인증 코드가 올바르지 않습니다."
        case .emailAlreadyExists: return "해당 이메일로 이미 가입된 계정이 존재합니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .tokenSaveError: return "인증 토큰을 저장하는 중 오류가 발생했습니다."
        }
    }
    
    static func from(baseError: BaseError) -> SocialLoginError {
        switch baseError {
        case .UNAUTHORIZED: return .invalidCode
        case .BAD_REQUEST: return .emailAlreadyExists
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum WithdrawalError: Error {
    case userNotFound
    case emailNotMatch
    case networkError
    case unknown
    
    func localizedDescription() -> String {
        switch self {
        case .userNotFound: return "사용자를 찾을 수 없습니다."
        case .emailNotMatch: return "이메일이 올바르지 않습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    static func from(baseError: BaseError) -> WithdrawalError {
        switch baseError {
        case .UNAUTHORIZED: return .userNotFound
        case .NOT_FOUND: return .emailNotMatch
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

enum MemoError: Error {
    case wrongFormat
    case unsureUser
    case wrongUser
    case nonExistingMemo
    case serverError
    case invalidOrder
    case unknown
    
    func localizedDescription() -> String {
        switch self {
        case .wrongFormat: return "메모 형식이 올바르지 않습니다."
        case .unsureUser: return "사용자 인증에 실패했습니다."
        case .wrongUser: return "다른 사용자의 메모에 접근할 수 없습니다."
        case .nonExistingMemo: return "해당 메모를 찾을 수 없습니다."
        case .serverError: return "서버 오류가 발생했습니다."
        case .invalidOrder: return "잘못된 순서입니다."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    static func from(baseError: BaseError) -> MemoError {
        switch baseError {
        case .BAD_REQUEST: return .wrongFormat
        case .UNAUTHORIZED: return .unsureUser
        case .FORBIDDEN: return .wrongUser
        case .NOT_FOUND: return .nonExistingMemo
        case .INTERNAL_SERVER_ERROR: return .serverError
        default: return .unknown
        }
    }
}

enum TagError: Error {
    case wrongFormat
    case unsureUser
    case wrongUser
    case nonExistingTag
    case serverError
    case unknown
    
    func localizedDescription() -> String {
        switch self {
        case .wrongFormat: return "태그 형식이 올바르지 않습니다."
        case .unsureUser: return "사용자 인증에 실패했습니다."
        case .wrongUser: return "다른 사용자의 태그에 접근할 수 없습니다."
        case .nonExistingTag: return "해당 태그를 찾을 수 없습니다."
        case .serverError: return "서버 오류가 발생했습니다."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    static func from(baseError: BaseError) -> TagError {
        switch baseError {
        case .BAD_REQUEST: return .wrongFormat
        case .UNAUTHORIZED: return .unsureUser
        case .FORBIDDEN: return .wrongUser
        case .NOT_FOUND: return .nonExistingTag
        case .INTERNAL_SERVER_ERROR: return .serverError
        default: return .unknown
        }
    }
}

