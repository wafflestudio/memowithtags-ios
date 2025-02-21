//
//  CreateMemoUseCase.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/29/24.
//

import Foundation

protocol CreateMemoUseCase {
    func execute(content: String, tagIds: [Int], locked: Bool) async -> Result<Memo, MemoError>
}

class DefaultCreateMemoUseCase: CreateMemoUseCase {
    private let memoRepository: MemoRepository

    init(memoRepository: MemoRepository) {
        self.memoRepository = memoRepository
    }

    func execute(content: String, tagIds: [Int], locked: Bool) async -> Result<Memo, MemoError> {
        do {
            let dto = try await memoRepository.createMemo(content: content, tagIds: tagIds, locked: locked)
            let memo = dto.toMemo()
            return .success(memo)
        } catch let error as BaseError {
            return .failure(.from(baseError: error))
        } catch {
            return .failure(.unknown)
        }
    }
}
