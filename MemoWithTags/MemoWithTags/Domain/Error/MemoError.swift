//
//  MemoError.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/23/25.
//
enum MemoError: Error {
    case wrongFormat
    case unsureUser
    case wrongUser
    case nonExistingMemo
    case serverError
    case invalidOrder
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .wrongFormat: return "메모 형식이 올바르지 않습니다."
        case .unsureUser: return "사용자 인증에 실패했습니다. 다시 로그인해 주세요."
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
