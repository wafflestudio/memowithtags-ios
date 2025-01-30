//
//  CreateTagUseCase.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/29/24.
//

import Foundation
import SwiftUI

protocol CreateTagUseCase {
    func execute(id: UUID, name: String, color: Color.TagColor, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async -> Result<Tag, TagError>
}

class DefaultCreateTagUseCase: CreateTagUseCase {
    private let tagRepository: TagRepository

    init(tagRepository: TagRepository) {
        self.tagRepository = tagRepository
    }

    func execute(id: UUID, name: String, color: Color.TagColor, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async -> Result<Tag, TagError> {
        do {
            let dto = try await tagRepository.createTag(id: id, name: name, colorHex: color.rawValue, embeddingVector: embeddingVector, createdAt: createdAt, updatedAt: updatedAt)
            let tag = dto.toTag()
            return .success(tag)
        } catch let error as BaseError {
            return .failure(.from(baseError: error))
        } catch {
            return .failure(.unknown)
        }
    }
}
