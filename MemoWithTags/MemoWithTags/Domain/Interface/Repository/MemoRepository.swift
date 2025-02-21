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
    func createMemo(content: String, tagIds: [Int], locked: Bool) async throws -> MemoDto
    func deleteMemo(memoId: Int) async throws
    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async throws -> MemoDto
}
