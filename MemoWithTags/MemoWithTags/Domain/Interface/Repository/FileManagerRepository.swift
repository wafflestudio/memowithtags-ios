//
//  FileManagerRepository.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/29/25.
//

import Foundation

protocol FileManagerRepository: BaseRepository {
    func userChanged(userId: String)
    func loadMemosAndTags() async throws -> (memos: [Memo], tags: [Tag])
    func saveMemosAndTags(memos: [Memo], tags: [Tag]) async throws
}
