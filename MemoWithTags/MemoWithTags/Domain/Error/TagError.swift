//
//  Error.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/2/25.
//

import Foundation

enum TagError: CustomError {
    case unsureUser
    case wrongUser
    case nonExistingTag
    case serverError
    case unknown
    
    var type: ErrorType {
        switch self {
        case .unsureUser:
            return .relogin
        default:
            return .normal
        }
    }
    
    static func from(baseError: BaseError) -> TagError {
        switch baseError.code {
        case .USER_AUTHENTICATION_FAILED: return .unsureUser
        case .TAG_NOT_OWNED_BY_USER: return .wrongUser
        case .TAG_NOT_FOUND: return .nonExistingTag
        case .CONNECT_FAILED: return .serverError
        default: return .unknown
        }
    }
}

extension TagError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsureUser: return "사용자 인증에 실패했습니다. 다시 로그인해 주세요."
        case .wrongUser: return "다른 사용자의 태그에 접근할 수 없습니다."
        case .nonExistingTag: return "해당 태그를 찾을 수 없습니다."
        case .serverError: return "서버 오류가 발생했습니다."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
}
