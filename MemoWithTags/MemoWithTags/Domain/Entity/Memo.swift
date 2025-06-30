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
    
    var state: MemoState = .idle
}

enum MemoState: Codable {
    case idle         // 정상 상태
    case creating     // 생성 중
    case updating     // 수정 중
    case deleting     // 삭제 중
}

struct PaginatedMemos {
    let memos: [Memo]
    let currentPage: Int
    let totalPages: Int
}
