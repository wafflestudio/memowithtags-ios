//
//  DefaultMemoRepository.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation
import Alamofire

final class DefaultMemoRepository: MemoRepository {
    
    let tokenInterceptor = TokenInterceptor()
    
    func fetchMemos(content: String?, tagIds: [Int]?, dateRange: ClosedRange<Date>?, page: Int) async throws -> MemoResponseDto {
        print("fetch memos")
        let response = await AF.request(
            MemoRouter.fetchMemos(content: content, tagIds: tagIds, dateRange: dateRange, page: page),
            interceptor: tokenInterceptor
        ).serializingDecodable(MemoResponseDto.self).response
        
        let dto = try handleErrorDecodable(response: response)
        
        return dto
    }

    func createMemo(id: UUID, content: String, tagIds: [UUID], locked: Bool, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async throws -> MemoDto {
        print("create memo")
        let response = await AF.request(
            MemoRouter.createMemo(id: id, content: content, tagIds: tagIds, locked: locked, embeddingVector: embeddingVector, createdAt: createdAt, updatedAt: updatedAt), interceptor: tokenInterceptor
        ).serializingDecodable(MemoDto.self).response
        let dto = try handleErrorDecodable(response: response)

        return dto
    }

    func deleteMemo(id: UUID) async throws {
        print("delete memo")
        let response = await AF.request(
            MemoRouter.deleteMemo(id: id), interceptor: tokenInterceptor
        ).serializingData().response
        try handleError(response: response)
    }

    func updateMemo(id: UUID, content: String, tagIds: [UUID], locked: Bool, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async throws -> MemoDto {
        print("update memo")
        let response = await AF.request(
            MemoRouter.updateMemo(id: id, content: content, tagIds: tagIds, locked: locked, embeddingVector: embeddingVector, createdAt: createdAt, updatedAt: updatedAt),
            interceptor: tokenInterceptor
        ).serializingDecodable(MemoDto.self).response
        let dto = try handleErrorDecodable(response: response)
        
        return dto
    }
}
