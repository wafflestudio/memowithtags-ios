//
//  DeleteMemoUseCase.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/29/24.
//

import Foundation

protocol DeleteMemoUseCase {
    func execute(memoId: Int) async -> Result<Void, MemoError>
}

class DefaultDeleteMemoUseCase: DeleteMemoUseCase {
    private let memoRepository: MemoRepository

    init(memoRepository: MemoRepository) {
        self.memoRepository = memoRepository
    }

    func execute(memoId: Int) async -> Result<Void, MemoError> {
        do {
            try await memoRepository.deleteMemo(memoId: memoId)
            return .success(())
        } catch let error as BaseError {
            return .failure(.from(baseError: error))
        } catch {
            return .failure(.unknown)
        }
    }
}
