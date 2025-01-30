//
//  FileManagerError.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/30/25.
//

import Foundation

enum FileManagerError: Error, LocalizedError {
    case fileNotFound
    case fileAlreadyExists
    case invalidPath
    case permissionDenied
    case outOfSpace
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "파일을 찾을 수 없습니다."
        case .fileAlreadyExists:
            return "파일이 이미 존재합니다."
        case .invalidPath:
            return "잘못된 파일 경로입니다."
        case .permissionDenied:
            return "파일에 대한 권한이 거부되었습니다."
        case .outOfSpace:
            return "디스크 공간이 부족합니다."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    /// NSError를 FileManagerError로 변환하는 초기화 메서드
    init(_ error: Error) {
        let nsError = error as NSError
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileNoSuchFileError:
                self = .fileNotFound
            case NSFileWriteFileExistsError:
                self = .fileAlreadyExists
            case NSFileWriteOutOfSpaceError:
                self = .outOfSpace
            case NSFileReadNoPermissionError, NSFileWriteNoPermissionError:
                self = .permissionDenied
            default:
                self = .unknown(error)
            }
        } else {
            self = .unknown(error)
        }
    }
}
