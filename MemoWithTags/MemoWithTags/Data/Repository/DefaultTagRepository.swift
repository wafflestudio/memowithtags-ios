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
    
    func fetchTags() async throws -> [TagDto] {
        print("fetch tag")
        let response = await AF.request(TagRouter.fetchTags, interceptor: tokenInterceptor).serializingDecodable([TagDto].self).response
        let dto = try handleErrorDecodable(response: response)
    
        return dto
    }

    func createTag(id: UUID, name: String, colorHex: String, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async throws -> TagDto {
        print("create tag")
        let response = await AF.request(
            TagRouter.createTag(id: id, name: name, colorHex: colorHex, embeddingVector: embeddingVector, createdAt: createdAt, updatedAt: updatedAt), interceptor: tokenInterceptor
        ).serializingDecodable(TagDto.self).response
        let dto = try handleErrorDecodable(response: response)
        return dto
    }

    func deleteTag(id: UUID) async throws {
        print("delete tag")
        let response =  await AF.request(
            TagRouter.deleteTag(id: id), interceptor: tokenInterceptor
        ).serializingData().response
        try handleError(response: response)
    }

    func updateTag(id: UUID, name: String, colorHex: String, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async throws -> TagDto {
        print("update tag")
        let response = await AF.request(
            TagRouter.updateTag(id: id, name: name, colorHex: colorHex, embeddingVector: embeddingVector, createdAt: createdAt, updatedAt: updatedAt), interceptor: tokenInterceptor
        ).serializingDecodable(TagDto.self).response
        let dto = try handleErrorDecodable(response: response)
        
        return dto
    }
}
