//
//  Memo.swift
//  MemoWithTags
//
//  Created by 최진모 on 12/26/24.
//
import Foundation

struct Memo: Codable, Identifiable, Equatable  {
    let id: UUID
    var content: String
    var tagIds: [UUID]
    var locked: Bool
    var embeddingVector: [Float]
    var createdAt: Date
    var updatedAt: Date
}

struct PaginatedMemos {
    let memos: [Memo]
    let currentPage: Int
    let totalPages: Int
}
