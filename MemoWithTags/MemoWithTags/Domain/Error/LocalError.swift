//
//  LocalError.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/19/25.
//

import Foundation

enum LocalError: CustomError, LocalizedError {
    case encodingFailed
    case decodingFailed
    
    var type: ErrorType {
        .normal
    }
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "객체를 저장하는 데 실패했습니다."
        case .decodingFailed:
            return "저장된 데이터를 불러오는 데 실패했습니다."
        }
    }
}
