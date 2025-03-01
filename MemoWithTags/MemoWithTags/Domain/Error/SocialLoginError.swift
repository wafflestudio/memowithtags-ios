//
//  SocialAuthError.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/23/25.
//

import Foundation

enum SocialLoginError: CustomError {
    case invalidCode
    case emailAlreadyExists
    case networkError
    case unknown
    case tokenSaveError
    case invalidAccess
    
    var type: ErrorType {
        switch self {
        default:
            return .normal
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

extension SocialLoginError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCode: return "소셜 로그인에 실패했습니다. 다시 시도해주세요."
        case .emailAlreadyExists: return "해당 이메일로 이미 가입된 계정이 존재합니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .tokenSaveError: return "인증 토큰을 저장하는 중 오류가 발생했습니다."
        case .invalidAccess: return "유효하지 않은 접근입니다."
        }
    }
}
