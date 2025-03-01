//
//  CustomError.swift
//  MemoWithTags
//
//  Created by 최진모 on 3/2/25.
//

// MARK: - 에러 유형
enum ErrorType {
    case normal           // 일반적인 에러
    case relogin
    case fatal              // 치명적인 에러
}

// MARK: - 공통 에러 프로토콜
protocol CustomError: Error {
    var type: ErrorType { get }
}
