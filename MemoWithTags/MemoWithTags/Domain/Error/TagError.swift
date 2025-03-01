//
//  Error.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/2/25.
//

import Foundation

enum TagError: CustomError {
    case wrongFormat
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

extension TagError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .wrongFormat: return "태그 형식이 올바르지 않습니다."
        case .unsureUser: return "사용자 인증에 실패했습니다. 다시 로그인해 주세요."
        case .wrongUser: return "다른 사용자의 태그에 접근할 수 없습니다."
        case .nonExistingTag: return "해당 태그를 찾을 수 없습니다."
        case .serverError: return "서버 오류가 발생했습니다."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
}
