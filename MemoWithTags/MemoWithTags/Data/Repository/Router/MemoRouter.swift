//
//  MemoRouter.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import Alamofire
import Foundation

enum MemoRouter: Router {
    case fetchMemos(content: String?, tagIds: [Int]?, dateRange: ClosedRange<Date>?, page: Int)
    case createMemo(id: UUID, content: String, tagIds: [UUID], locked: Bool, embeddingVector: [Float], createdAt: Date, updatedAt: Date)
    case deleteMemo(id: UUID)
    case updateMemo(id: UUID, content: String, tagIds: [UUID], locked: Bool, embeddingVector: [Float], createdAt: Date, updatedAt: Date)
    
    var baseURL: URL {
        return URL(string: NetworkConfiguration.baseURL)!
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchMemos:
            return .get
        case .createMemo:
            return .post
        case .deleteMemo:
            return .delete
        case .updateMemo:
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .fetchMemos:
            return "/search-memo"
        case .createMemo:
            return "/memo"
        case let .deleteMemo(id), let .updateMemo(id, _, _, _, _, _, _):
            return "/memo/\(id)"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .fetchMemos(content, tagIds, dateRange, page):
            var params: [String: Any] = ["page": page]
            if let content = content {
                params["content"] = content
            }
            // tagIds가 빈 리스트여도 params에서 제거한다.
            if let tagIds = tagIds, !tagIds.isEmpty {
                params["tagIds"] = tagIds.map { String($0) }.joined(separator: ",")
            }
            if let dateRange = dateRange {
                let formatter = ISO8601DateFormatter()
                params["startDate"] = formatter.string(from: dateRange.lowerBound)
                params["endDate"] = formatter.string(from: dateRange.upperBound)
            }
            return params
        case let .createMemo(id, content, tagIds, locked, embeddingVector, createdAt, updatedAt):
            return ["id": id, "content": content, "tagIds": tagIds, "locked": locked, "embeddingVector": embeddingVector, "createdAt": createdAt, "updatedAt": updatedAt]
        case let .updateMemo(id, content, tagIds, locked, embeddingVector, createdAt, updatedAt):
            return ["content": content, "tagIds": tagIds, "locked": locked, "embeddingVector": embeddingVector, "createdAt": createdAt, "updatedAt": updatedAt]
        case .deleteMemo:
            return nil
        }
    }
}
