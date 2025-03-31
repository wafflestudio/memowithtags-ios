//
//  AuthError.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/23/25.
//
import Foundation

//MARK: - 로그인 에러
enum LoginError: CustomError {
    case invalidCredentials
    case networkError
    case unknown
    case tokenSaveError
    case invalidEmail
    
    var type: ErrorType {
        return .normal
    }
    
    static func from(baseError: BaseError) -> LoginError {
        switch baseError.code {
        case .USER_SIGN_IN_INVALID: return .invalidCredentials
        case .CONNECT_FAILED: return .networkError
        default: return .unknown
        }
    }
}

extension LoginError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "이메일 또는 비밀번호가 잘못되었습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .tokenSaveError: return "인증 토큰을 저장하는 중 오류가 발생했습니다."
        case .invalidEmail: return "이메일 형식이 잘못되었습니다."
        }
    }
}

//MARK: - 로그아웃 에러
enum LogoutError: CustomError {
    case tokenDeleteError
    
    var type: ErrorType {
        return .normal
    }
}

extension LogoutError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .tokenDeleteError: return "로그아웃 처리 중 오류가 발생했습니다."
        }
    }
}

//MARK: - 인증코드 전송 에러
enum SendCodeError: CustomError {
    case alreadySentCode
    case invalidEmail
    case networkError
    case unknown
    
    var type: ErrorType {
        return .normal
    }
    
    static func from(baseError: BaseError) -> SendCodeError {
        switch baseError.code {
        case .USER_UNABLE_TO_SEND_EMAIL: return .alreadySentCode
        case .CONNECT_FAILED: return .networkError
        default: return .unknown
        }
    }
}

extension SendCodeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .alreadySentCode: return "중복된 요청입니다."
        case .invalidEmail: return "이메일 형식이 잘못되었습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
}

//MARK: - 인증코드 검증 에러
enum VerifyCodeError: CustomError {
    case notMatchCode
    case networkError
    case unknown
    
    var type: ErrorType {
        return .normal
    }
    
    static func from(baseError: BaseError) -> VerifyCodeError {
        switch baseError.code {
        case .USER_MAIL_VERIFICATION_FAILED: return .notMatchCode
        case .CONNECT_FAILED: return .networkError
        default: return .unknown
        }
    }
}

extension VerifyCodeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notMatchCode: return "인증코드가 올바르지 않습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
}

//MARK: - 회원가입 에러
enum RegisterError: CustomError {
    case emailAlreadyExists
    case emailNotVerified
    case invalidEmail
    case invalidNickname
    case invalidPassword
    case passwordNotMatch
    case tokenSaveError
    case networkError
    case unknown
    
    var type: ErrorType {
        return .normal
    }
    
    static func from(baseError: BaseError) -> RegisterError {
        switch baseError.code {
        case .USER_EMAIL_ALREADY_EXISTS: return .emailAlreadyExists
        case .USER_EMAIL_NOT_VERIFIED: return .emailNotVerified
        case .USER_WRONG_EMAIL_FORMAT: return .invalidEmail
        case .USER_WRONG_NICKNAME_FORMAT: return .invalidNickname
        case .USER_WRONG_PASSWORD_FORMAT: return .invalidPassword
        case .CONNECT_FAILED: return .networkError
        default: return .unknown
        }
    }
}

extension RegisterError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emailAlreadyExists: return "이미 사용중인 이메일입니다."
        case .emailNotVerified: return "인증이 완료되지 않은 이메일입니다."
        case .invalidEmail: return "이메일 형식이 잘못되었습니다."
        case .invalidNickname: return "닉네임 형식이 잘못되었습니다."
        case .invalidPassword: return "비밀번호 형식이 잘못되었습니다."
        case .passwordNotMatch: return "비밀번호가 일치하지 않습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .tokenSaveError: return "인증 토큰을 저장하는 중 오류가 발생했습니다."
        }
    }
}


//MARK: - 비밀번호 재설정 에러
enum ResetPasswordError: CustomError {
    case emailNotVerified
    case userNotFound
    case invalidPassword
    case passwordNotMatch
    case networkError
    case unknown
    
    var type: ErrorType {
        return .normal
    }
    
    static func from(baseError: BaseError) -> ResetPasswordError {
        switch baseError.code {
        case .USER_EMAIL_NOT_VERIFIED: return .emailNotVerified
        case .USER_NOT_FOUND: return .userNotFound
        case .CONNECT_FAILED: return .networkError
        default: return .unknown
        }
    }
}

extension ResetPasswordError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emailNotVerified: return "인증이 완료되지 않은 이메일입니다."
        case .userNotFound: return "존재하지 않는 유저입니다."
        case .invalidPassword: return "비밀번호 형식이 잘못되었습니다."
        case .passwordNotMatch: return "비밀번호가 일치하지 않습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
}
