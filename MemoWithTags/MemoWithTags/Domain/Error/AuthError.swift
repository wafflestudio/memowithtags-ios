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
    
    static func from(baseError: ServerError) -> LoginError {
        switch baseError.code {
        case .UNAUTHORIZED: return .invalidCredentials
        case .INTERNAL_SERVER_ERROR: return .networkError
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
        switch baseError {
        case .BAD_REQUEST: return .alreadySentCode
        case .INTERNAL_SERVER_ERROR: return .networkError
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
        switch baseError {
        case .UNAUTHORIZED: return .notMatchCode
        case .INTERNAL_SERVER_ERROR: return .networkError
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
    case invalidEmail
    case networkError
    case unknown
    case tokenSaveError
    case invalidPassword
    case passwordNotMatch
    
    var type: ErrorType {
        return .normal
    }
    
    static func from(baseError: BaseError) -> RegisterError {
        switch baseError {
        case .CONFLICT: return .emailAlreadyExists
        case .BAD_REQUEST: return .invalidEmail
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

extension RegisterError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emailAlreadyExists: return "이미 사용중인 이메일입니다."
        case .invalidEmail: return "인증에 실패한 이메일입니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .tokenSaveError: return "인증 토큰을 저장하는 중 오류가 발생했습니다."
        case .invalidPassword: return "비밀번호 형식이 잘못되었습니다."
        case .passwordNotMatch: return "비밀번호가 일치하지 않습니다."
        }
    }
}


//MARK: - 비밀번호 재설정 에러
enum ResetPasswordError: CustomError {
    case invalidEmail
    case networkError
    case unknown
    case invalidPassword
    case passwordNotMatch
    
    var type: ErrorType {
        return .normal
    }
    
    static func from(baseError: BaseError) -> ResetPasswordError {
        switch baseError {
        case .BAD_REQUEST: return .invalidEmail
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

extension ResetPasswordError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidEmail: return "인증에 실패한 이메일입니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .invalidPassword: return "비밀번호 형식이 잘못되었습니다."
        case .passwordNotMatch: return "비밀번호가 일치하지 않습니다."
        }
    }
}
