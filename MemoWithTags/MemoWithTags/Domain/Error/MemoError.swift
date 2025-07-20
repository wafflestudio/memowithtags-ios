//
//  MemoError.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/23/25.
//
import Foundation

enum MemoError: CustomError {
    case unsureUser
    case wrongUser
    case nonExistingMemo
    case nonExistingTag
    case serverError
    case invalidOrder
    case unknown
    case cancelled
    
    var type: ErrorType {
        switch self {
        case .unsureUser:
            return .relogin
        case .cancelled:
            return .ignore
        default:
            return .normal
        }
    }

    static func from(baseError: BaseError) -> MemoError {
        switch baseError.code {
        case .USER_AUTHENTICATION_FAILED: return .unsureUser
        case .MEMO_ACCESS_DENIED: return .wrongUser
        case .MEMO_NOT_FOUND: return .nonExistingMemo
        case .TAG_NOT_FOUND: return .nonExistingTag
        case .CONNECT_FAILED: return .serverError
        case .CANCELLED: return .cancelled
        default: return .unknown
        }
    }
}

extension MemoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsureUser: return "사용자 인증에 실패했습니다. 다시 로그인해 주세요."
        case .wrongUser: return "다른 사용자의 메모에 접근할 수 없습니다."
        case .nonExistingMemo: return "해당 메모를 찾을 수 없습니다."
        case .nonExistingTag: return "해당 태그를 찾을 수 없습니다."
        case .serverError: return "서버 오류가 발생했습니다."
        case .invalidOrder: return "잘못된 순서입니다."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        case .cancelled: return "서버 통신이 취소되었습니다."
        }
    }
}
