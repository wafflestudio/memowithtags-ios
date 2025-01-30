//
//  MemoRepository.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/29/24.
//

import Foundation
import Alamofire

protocol MemoRepository: BaseRepository {
    func fetchMemos(content: String?, tagIds: [Int]?, dateRange: ClosedRange<Date>?, page: Int) async throws -> MemoResponseDto
    func createMemo(id: UUID, content: String, tagIds: [UUID], locked: Bool, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async throws -> MemoDto
    func updateMemo(id: UUID, content: String, tagIds: [UUID], locked: Bool, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async throws -> MemoDto
    func deleteMemo(id: UUID) async throws
}
