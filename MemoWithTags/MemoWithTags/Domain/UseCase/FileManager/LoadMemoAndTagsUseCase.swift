//
//  LoadMemosAndTagsUseCase.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/29/25.
//

import Foundation

protocol LoadMemosAndTagsUseCase {
    func execute() async -> Result<(memos: [Memo], tags: [Tag]), FileManagerError>
}

final class DefaultLoadMemosAndTagsUseCase: LoadMemosAndTagsUseCase {
    private let fileManagerRepository: FileManagerRepository

    init(fileManagerRepository: FileManagerRepository) {
        self.fileManagerRepository = fileManagerRepository
    }
    
    func execute() async -> Result<(memos: [Memo], tags: [Tag]), FileManagerError> {
        do {
            let result = try await fileManagerRepository.loadMemosAndTags()
            return .success(result)
        } catch let error as FileManagerError {
            return .failure(error)
        } catch {
            return .failure(.unknown(error))
        }
    }
}
