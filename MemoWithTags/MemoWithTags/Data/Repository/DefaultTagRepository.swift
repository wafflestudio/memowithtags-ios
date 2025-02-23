//
//  DefaultTagRepository.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation
import Alamofire

final class DefaultTagRepository: TagRepository {
    
    let tokenInterceptor = TokenInterceptor()
    
    //MARK: - 태그 가져오기
    func fetchTags() async throws -> [TagDto] {
        print("🙏 fetch tag")
        let response = await AF.request(TagRouter.fetchTags, interceptor: tokenInterceptor).serializingDecodable([TagDto].self).response
        let dto = try handleErrorDecodable(response: response)
    
        return dto
    }

    //MARK: - 태그 생성
    func createTag(name: String, colorHex: String) async throws -> TagDto {
        print("🙏 create tag")
        let response = await AF.request(
            TagRouter.createTag(name: name, colorHex: colorHex), interceptor: tokenInterceptor
        ).serializingDecodable(TagDto.self).response
        let dto = try handleErrorDecodable(response: response)
        return dto
    }

    //MARK: - 태그 삭제
    func deleteTag(tagId: Int) async throws {
        print("🙏 delete tag")
        let response =  await AF.request(
            TagRouter.deleteTag(tagId: tagId), interceptor: tokenInterceptor
        ).serializingData().response
        try handleError(response: response)
    }

    //MARK: - 태그 수정
    func updateTag(tagId: Int, name: String, colorHex: String) async throws -> TagDto {
        print("🙏 update tag")
        let response = await AF.request(
            TagRouter.updateTag(tagId: tagId, name: name, colorHex: colorHex), interceptor: tokenInterceptor
        ).serializingDecodable(TagDto.self).response
        let dto = try handleErrorDecodable(response: response)
        
        return dto
    }
}

