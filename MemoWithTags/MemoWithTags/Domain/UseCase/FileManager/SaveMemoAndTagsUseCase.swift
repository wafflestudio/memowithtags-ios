//
//  SaveMemosAndTagsUseCase.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/29/25.
//

import Foundation

protocol SaveMemosAndTagsUseCase {
    func execute(memos: [Memo], tags: [Tag]) async -> Result<Void, FileManagerError>
}

final class DefaultSaveMemosAndTagsUseCase: SaveMemosAndTagsUseCase {
    private let fileManagerRepository: FileManagerRepository

    init(fileManagerRepository: FileManagerRepository) {
        self.fileManagerRepository = fileManagerRepository
    }
    
    func execute(memos: [Memo], tags: [Tag]) async -> Result<Void, FileManagerError> {
        do {
            try await fileManagerRepository.saveMemosAndTags(memos: memos, tags: tags)
            return .success(())
        } catch let error as FileManagerError {
            return .failure(error)
        } catch {
            return .failure(.unknown(error))
        }
    }
}
