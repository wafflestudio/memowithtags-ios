//
//  DefaultMemoRepository.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation
import Alamofire
import Factory

final class DefaultMemoRepository: MemoRepository {
    
    let tokenInterceptor = TokenInterceptor()
    
    //MARK: - 메모 가져오기
    func searchMemos(content: String?, tagIds: [Int]?, dateRange: ClosedRange<Date>?, page: Int) async throws -> MemoResponseDto {
        print("🙏 search memos")
        let response = await AF.request(
            MemoRouter.searchMemos(content: content, tagIds: tagIds, dateRange: dateRange, page: page),
            interceptor: tokenInterceptor
        ).serializingDecodable(MemoResponseDto.self).response
        
        let dto = try handleErrorDecodable(response: response)
        
        return dto
    }

    //MARK: - 메모 생성
    func createMemo(content: String, tagIds: [Int], locked: Bool) async throws -> MemoDto {
        print("🙏 create memo")
        let response = await AF.request(
            MemoRouter.createMemo(content: content, tagIds: tagIds, locked: locked), interceptor: tokenInterceptor
        ).serializingDecodable(MemoDto.self).response
        let dto = try handleErrorDecodable(response: response)

        return dto
    }

    //MARK: - 메모 삭제
    func deleteMemo(memoId: Int) async throws {
        print("🙏 delete memo")
        let response = await AF.request(
            MemoRouter.deleteMemo(memoId: memoId), interceptor: tokenInterceptor
        ).validate(statusCode: 200..<300).serializingData().response
        try handleError(response: response)
    }

    //MARK: - 메모 수정
    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async throws -> MemoDto {
        print("🙏 update memo")
        let response = await AF.request(
            MemoRouter.updateMemo(memoId: memoId, content: content, tagIds: tagIds, locked: locked),
            interceptor: tokenInterceptor
        ).serializingDecodable(MemoDto.self).response
        let dto = try handleErrorDecodable(response: response)
        
        return dto
    }
    
    // MARK: - 메모 추천
    func recommendMemos(content: String?, tagIds: [Int]?) async throws -> RecommendMemoResponseDto {
        print("🙏 recommend memos")
        let response = await AF.request(
            MemoRouter.recommendMemos(content: content, tagIds: tagIds),
            interceptor: tokenInterceptor
        ).serializingDecodable(RecommendMemoResponseDto.self).response

        let dto = try handleErrorDecodable(response: response)
        return dto
    }

    // MARK: - memoId로 주변 메모 fetch
    func fetchMemosByMemoId(memoId: Int) async throws -> MemoResponseDto {
        print("🙏 fetch memos by memoId")
        let response = await AF.request(
            MemoRouter.fetchMemosByMemoId(memoId: memoId),
            interceptor: tokenInterceptor
        ).serializingDecodable(MemoResponseDto.self).response

        let dto = try handleErrorDecodable(response: response)
        return dto
    }
}

extension Container {
    var memoRepository: Factory<MemoRepository> {
        self { DefaultMemoRepository() }.singleton
    }
}

