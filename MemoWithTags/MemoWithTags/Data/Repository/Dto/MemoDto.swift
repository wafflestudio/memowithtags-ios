//
//  MemoDto.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation

struct MemoDto: Decodable {
    let id: UUID
    let content: String
    let tagIds: [UUID]
    let locked: Bool
    let embeddingVector: [Float]
    let createdAt: String
    let updatedAt: String

    func toMemo() -> Memo {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return Memo(
            id: id,
            content: content,
            tagIds: tagIds,
            locked: locked,
            embeddingVector: embeddingVector,
            createdAt: dateFormatter.date(from: createdAt) ?? Date(),
            updatedAt: dateFormatter.date(from: updatedAt) ?? Date()
        )
    }
}

struct MemoResponseDto: Decodable {
    let page: Int
    let results: [MemoDto]
    let totalPages: Int
    let totalResults: Int
    
    func toPaginatedMemos() -> PaginatedMemos {
        return .init(memos: results.map{$0.toMemo()}, currentPage: page, totalPages: totalPages)
    }
}
