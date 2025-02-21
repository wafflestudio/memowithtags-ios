//
//  FetchMemoUseCase.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/29/24.
//

import Foundation

protocol FetchMemoUseCase {
    func execute(content: String?, tagIds: [Int]?, dateRange: ClosedRange<Date>?, page: Int) async -> Result<PaginatedMemos, MemoError>
}

class DefaultFetchMemoUseCase: FetchMemoUseCase {
    private let memoRepository: MemoRepository

    init(memoRepository: MemoRepository) {
        self.memoRepository = memoRepository
    }

    func execute(content: String?, tagIds: [Int]?, dateRange: ClosedRange<Date>?, page: Int) async -> Result<PaginatedMemos, MemoError> {
        do {
            let dto = try await memoRepository.fetchMemos(content: content, tagIds: tagIds, dateRange: dateRange, page: page)
            let paginatedMemos = dto.toPaginatedMemos()
            return .success(paginatedMemos)
        } catch let error as BaseError {
            return .failure(.from(baseError: error))
        } catch {
            return .failure(.unknown)
        }
    }
}
