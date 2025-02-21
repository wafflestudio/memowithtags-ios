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

    func createMemo(content: String, tagIds: [Int], locked: Bool) async throws -> MemoDto {
        print("create memo")
        let response = await AF.request(
            MemoRouter.createMemo(content: content, tagIds: tagIds, locked: locked), interceptor: tokenInterceptor
        ).serializingDecodable(MemoDto.self).response
        let dto = try handleErrorDecodable(response: response)

        return dto
    }

    func deleteMemo(memoId: Int) async throws {
        print("delete memo")
        let response = await AF.request(
            MemoRouter.deleteMemo(memoId: memoId), interceptor: tokenInterceptor
        ).serializingData().response
        try handleError(response: response)
    }

    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async throws -> MemoDto {
        print("update memo")
        let response = await AF.request(
            MemoRouter.updateMemo(memoId: memoId, content: content, tagIds: tagIds, locked: locked),
            interceptor: tokenInterceptor
        ).serializingDecodable(MemoDto.self).response
        let dto = try handleErrorDecodable(response: response)
        
        return dto
    }
}


