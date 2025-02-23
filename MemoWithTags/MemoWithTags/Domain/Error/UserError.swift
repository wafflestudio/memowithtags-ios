//
//  UserError.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/23/25.
//

//MARK: - 유저 정보 가져오기 에러
enum GetUserError: Error {
    case userNotFound
    case networkError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .userNotFound: return "사용자를 찾을 수 없습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    static func from(baseError: BaseError) -> GetUserError {
        switch baseError {
        case .UNAUTHORIZED: return .userNotFound
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

//MARK: - 닉네임 변경 에러
enum ChangeNicknameError: Error {
    case userNotFound
    case networkError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .userNotFound: return "닉네임 수정을 실패했습니다."
        case .networkError: return "네트워크 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    static func from(baseError: BaseError) -> ChangeNicknameError {
        switch baseError {
        case .UNAUTHORIZED: return .userNotFound
        case .INTERNAL_SERVER_ERROR: return .networkError
        default: return .unknown
        }
    }
}

//MARK: - 비밀번호 변경 에러
enum ChangePasswordError: Error {
    case userNotFound
    case notMatchCurrentPassword
    case networkError
    case unknown
    case invalidPassword
    case passwordNotMatch
    
    var localizedDescription: String {
        switch self {
        case .userNotFound: return "비밀번호 변경을 실패했습니다."
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

//MARK: - 회원 탈퇴 에러
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
