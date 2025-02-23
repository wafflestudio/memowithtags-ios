//
//  MemoService.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/22/25.
//

import Foundation

protocol MemoService {
    func createMemo(content: String, tagIds: [Int], locked: Bool) async -> Result<Memo, MemoError>
    func fetchMemo(content: String?, tagIds: [Int]?, dateRange: ClosedRange<Date>?, page: Int) async -> Result<PaginatedMemos, MemoError>
    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async -> Result<Memo, MemoError>
    func deleteMemo(memoId: Int) async -> Result<Void, MemoError>
}

final class DefaultMemoService: MemoService {
    private let memoRepository: MemoRepository

    init(memoRepository: MemoRepository) {
        self.memoRepository = memoRepository
    }
    
    //MARK: - 메모 생성
    func createMemo(content: String, tagIds: [Int], locked: Bool) async -> Result<Memo, MemoError> {
        do {
            let dto = try await memoRepository.createMemo(content: content, tagIds: tagIds, locked: locked)
            let memo = dto.toMemo()
            return .success(memo)
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 메모 가져오기
    func fetchMemo(content: String?, tagIds: [Int]?, dateRange: ClosedRange<Date>?, page: Int) async -> Result<PaginatedMemos, MemoError> {
        do {
            let dto = try await memoRepository.fetchMemos(content: content, tagIds: tagIds, dateRange: dateRange, page: page)
            let paginatedMemos = dto.toPaginatedMemos()
            return .success(paginatedMemos)
        } catch let error {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
    //MARK: - 메모 수정
    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async -> Result<Memo, MemoError> {
        do {
            let dto = try await memoRepository.updateMemo(memoId: memoId, content: content, tagIds: tagIds, locked: locked)
            let memo = dto.toMemo()
            return .success(memo)
        } catch let error {
            return .failure(.from(baseError: error as! BaseError ))
        }
    }
    
    //MARK: - 메모 삭제
    func deleteMemo(memoId: Int) async -> Result<Void, MemoError> {
        do {
            try await memoRepository.deleteMemo(memoId: memoId)
            return .success(())
        } catch let error  {
            return .failure(.from(baseError: error as! BaseError))
        }
    }
    
}
