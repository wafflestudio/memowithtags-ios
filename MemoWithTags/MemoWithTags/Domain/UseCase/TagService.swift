//
//  TagService.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/22/25.
//

import SwiftUI
import Factory

protocol TagService {
    func createTag(name: String, color: Color.TagColor) async -> Result<Tag, TagError>
    func fetchTag() async -> Result<[Tag], TagError>
    func updateTag(tagId: Int, name: String, color: Color.TagColor) async -> Result<Tag, TagError>
    func deleteTag(tagId: Int) async -> Result<Void, TagError>
}


final class DefaultTagServerice: TagService {
    @Injected(\.tagRepository) private var tagRepository: TagRepository

    //MARK: - 태그 생성
    func createTag(name: String, color: Color.TagColor) async -> Result<Tag, TagError> {
        do {
            let dto = try await tagRepository.createTag(name: name, colorHex: color.rawValue)
            let tag = dto.toTag()
            return .success(tag)
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 태그 가져오기
    func fetchTag() async -> Result<[Tag], TagError> {
        do {
            let dto = try await tagRepository.fetchTags()
            let tags = dto.map{ $0.toTag() }
            return .success(tags)
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 태그 수정
    func updateTag(tagId: Int, name: String, color: Color.TagColor) async -> Result<Tag, TagError> {
        do {
            let dto = try await tagRepository.updateTag(tagId: tagId, name: name, colorHex: color.rawValue)
            let tag = dto.toTag()
            return .success(tag)
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 태그 삭제
    func deleteTag(tagId: Int) async -> Result<Void, TagError> {
        do {
            try await tagRepository.deleteTag(tagId: tagId)
            return .success(())
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
}

extension Container {
    var tagService: Factory<TagService> {
        self { DefaultTagServerice() }.singleton
    }
}
