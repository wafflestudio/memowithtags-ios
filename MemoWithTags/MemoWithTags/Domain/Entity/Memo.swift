//
//  Memo.swift
//  MemoWithTags
//
//  Created by 최진모 on 12/26/24.
//
import Foundation

struct Memo: Codable, Identifiable, Equatable, Hashable  {
    let id: Int
    var content: String
    var tagIds: [TagID]
    var locked: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct PaginatedMemos {
    let memos: [Memo]
    let currentPage: Int
    let totalPages: Int
}
