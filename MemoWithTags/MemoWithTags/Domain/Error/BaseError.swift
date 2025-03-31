//
//  BaseError.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation

struct BaseError: Error, Decodable {
    let status: Int
    let code: ErrorCode // 옵셔널이 아니라 기본값을 갖도록 변경
    let message: String

    enum CodingKeys: CodingKey {
        case status
        case code
        case message
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Int.self, forKey: .status)
        
        // code 값을 ErrorCode enum으로 변환, 실패하면 .unknown
        let codeString = try container.decode(String.self, forKey: .code)
        self.code = ErrorCode(rawValue: codeString) ?? .UNKNOWN_ERROR
        
        self.message = try container.decode(String.self, forKey: .message)
        
        print("❌ ERROR\n❌ status: \(status)\n❌ code: \(code)")
    }
    
    init(status: Int, code: String, message: String) {
        self.status = status
        self.code = ErrorCode(rawValue: code) ?? .UNKNOWN_ERROR
        self.message = message
        
        print("❌ ERROR\n❌ status: \(status)\n❌ code: \(code)")
    }
}

enum ErrorCode: String {
    case USER_NOT_FOUND = "USER_NOT_FOUND"
    case USER_EMAIL_ALREADY_EXISTS = "USER_EMAIL_ALREADY_EXISTS"
    case USER_UNABLE_TO_SEND_EMAIL = "USER_UNABLE_TO_SEND_EMAIL"
    case USER_EMAIL_NOT_VERIFIED = "USER_EMAIL_NOT_VERIFIED"
    case USER_SIGN_IN_INVALID = "USER_SIGN_IN_INVALID"
    case USER_MAIL_VERIFICATION_FAILED = "USER_MAIL_VERIFICATION_FAILED"
    case USER_AUTHENTICATION_FAILED = "USER_AUTHENTICATION_FAILED"
    case USER_SOCIAL_LOGIN_FAILED = "USER_SOCIAL_LOGIN_FAILED"
    case USER_UPDATE_PASSWORD_INVALID = "USER_UPDATE_PASSWORD_INVALID"
    case USER_EMAIL_NOT_MATCHED = "USER_EMAIL_NOT_MATCHED"
    case USER_WRONG_EMAIL_FORMAT = "USER_WRONG_EMAIL_FORMAT"
    case USER_WRONG_PASSWORD_FORMAT = "USER_WRONG_PASSWORD_FORMAT"
    case USER_WRONG_NICKNAME_FORMAT = "USER_WRONG_NICKNAME_FORMAT"
    case USER_NOT_ADMIN = "USER_NOT_ADMIN"

    case MEMO_NOT_FOUND = "MEMO_NOT_FOUND"
    case MEMO_ACCESS_DENIED = "MEMO_ACCESS_DENIED"

    case TAG_NOT_FOUND = "TAG_NOT_FOUND"
    case TAG_NOT_OWNED_BY_USER = "TAG_NOT_OWNED_BY_USER"

    case TOKEN_EXPIRED = "TOKEN_EXPIRED"
    case TOKEN_INVALID_SIGNATURE = "TOKEN_INVALID_SIGNATURE"
    case TOKEN_INVALID = "TOKEN_INVALID"
    
    case CANT_DECODE = "CANT_DECODE"
    case CANT_DECODE_ERROR = "CANT_DECODE_ERROR"
    case CONNECT_FAILED = "CONNECT_FAILED"
    case UNKNOWN_ERROR = "UNKNOWN_ERROR"
}
