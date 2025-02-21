//
//  DeleteTagUseCase.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/29/24.
//

import Foundation

protocol DeleteTagUseCase {
    func execute(tagId: Int) async -> Result<Void, TagError>
}

class DefaultDeleteTagUseCase: DeleteTagUseCase {
    private let tagRepository: TagRepository

    init(tagRepository: TagRepository) {
        self.tagRepository = tagRepository
    }

    func execute(tagId: Int) async -> Result<Void, TagError>{
        do {
            try await tagRepository.deleteTag(tagId: tagId)
            return .success(())
        } catch let error as BaseError {
            return .failure(.from(baseError: error))
        } catch {
            return .failure(.unknown)
        }
    }
}
