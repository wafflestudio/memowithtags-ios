//
//  CreateMemoUseCase.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/29/24.
//

import Foundation

protocol CreateMemoUseCase {
    func execute(id: UUID, content: String, tagIds: [UUID], locked: Bool, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async -> Result<Memo, MemoError>
}

class DefaultCreateMemoUseCase: CreateMemoUseCase {
    private let memoRepository: MemoRepository

    init(memoRepository: MemoRepository) {
        self.memoRepository = memoRepository
    }

    func execute(id: UUID, content: String, tagIds: [UUID], locked: Bool, embeddingVector: [Float], createdAt: Date, updatedAt: Date) async -> Result<Memo, MemoError> {
        do {
            let dto = try await memoRepository.createMemo(id: id, content: content, tagIds: tagIds, locked: locked, embeddingVector: embeddingVector, createdAt: createdAt, updatedAt: updatedAt)
            let memo = dto.toMemo()
            return .success(memo)
        } catch let error as BaseError {
            return .failure(.from(baseError: error))
        } catch {
            return .failure(.unknown)
        }
    }
}
