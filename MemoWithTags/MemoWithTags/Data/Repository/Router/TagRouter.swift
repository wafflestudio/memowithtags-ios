//
//  TagRouter.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import Foundation
import Alamofire

enum TagRouter: Router {
    case fetchTags
    case createTag(id: UUID, name: String, colorHex: String, embeddingVector: [Float], createdAt: Date, updatedAt: Date)
    case deleteTag(id: UUID)
    case updateTag(id: UUID, name: String, colorHex: String, embeddingVector: [Float], createdAt: Date, updatedAt: Date)
    
    var baseURL: URL {
        return URL(string: NetworkConfiguration.baseURL)!
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchTags:
            return .get
        case .createTag:
            return .post
        case .deleteTag:
            return .delete
        case .updateTag:
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .fetchTags:
            return "/tag"
        case .createTag:
            return "/tag"
        case let .deleteTag(id):
            return "/tag/\(id)"
        case let .updateTag(id, _, _, _, _, _):
            return "/tag/\(id)"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchTags:
            return nil
        case let .createTag(id, name, colorHex, embeddingVector, createdAt, updatedAt):
            return ["id": id, "name": name, "colorHex": colorHex, "embeddingVector": embeddingVector, "createdAt": createdAt, "updatedAt": updatedAt]
        case .deleteTag:
            return nil
        case let .updateTag(id, name, colorHex, embeddingVector, createdAt, updatedAt):
            return ["id": id, "name": name, "colorHex": colorHex, "embeddingVector": embeddingVector, "createdAt": createdAt, "updatedAt": updatedAt]
        }
    }
}
