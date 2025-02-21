//
//  TagRepository.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/29/24.
//

import Alamofire

protocol TagRepository: BaseRepository {
    func fetchTags() async throws -> [TagDto]
    func createTag(name: String, colorHex: String) async throws -> TagDto
    func deleteTag(tagId: Int) async throws
    func updateTag(tagId: Int, name: String, colorHex: String) async throws -> TagDto
}

