//
//  TagRepository.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/29/24.
//

import Foundation
import Alamofire

protocol TagRepository: BaseRepository {
    func fetchTags() async throws -> [TagDto]
    func createTag(id: UUID, name: String, colorHex: String, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async throws -> TagDto
    func updateTag(id: UUID, name: String, colorHex: String, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async throws -> TagDto
    func deleteTag(id: UUID) async throws
}
