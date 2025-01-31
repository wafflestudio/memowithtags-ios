//
//  UserChangedUseCase.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/31/25.
//

import Foundation

protocol UserChangedUseCase {
    func execute(userId: String)
}

final class DefaultUserChangedUseCase: UserChangedUseCase {
    private let fileManagerRepository: FileManagerRepository

    init(fileManagerRepository: FileManagerRepository) {
        self.fileManagerRepository = fileManagerRepository
    }
    
    func execute(userId: String) {
        fileManagerRepository.userChanged(userId: userId)
    }
}
