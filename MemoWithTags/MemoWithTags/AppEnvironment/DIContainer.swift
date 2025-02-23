//
//  DIContainer.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation
import SwiftUI
///의존성 주입을 한번에 처리하는 컨테이너
struct DIContainer {
    var appState: AppState
    let useCases: UseCases
    
    init(appState: AppState) {
        self.appState = appState
        let repositories = DIContainer.configureRepositories()
        self.useCases = DIContainer.configureUseCases(repositories: repositories)
    }
}

extension DIContainer {
    struct UseCases {
        let authService: AuthService
        let memoService: MemoService
        let tagService: TagService
        let userService: UserService
        let socialLoginService: SocialLoginService
    }
}

extension DIContainer {
    struct Repositories {
        let authRepository: AuthRepository
        let memoRepository: MemoRepository
        let tagRepository: TagRepository
    }
}

extension DIContainer {
    private static func configureRepositories() -> Repositories {
        let authRepository = DefaultAuthRepository()
        let memoRepository = DefaultMemoRepository()
        let tagRepository = DefaultTagRepository()
        
        return .init(
            authRepository: authRepository,
            memoRepository: memoRepository,
            tagRepository: tagRepository
        )
    }
}

extension DIContainer {
    private static func configureUseCases(repositories: Repositories) -> UseCases {
        return .init(
            authService: DefaultAuthService(authRepository: repositories.authRepository),
            memoService: DefaultMemoService(memoRepository: repositories.memoRepository),
            tagService: DefaultTagServerice(tagRepository: repositories.tagRepository),
            userService: DefaultUserService(authRepository: repositories.authRepository),
            socialLoginService: DefaultSocialLoginService(authRepository: repositories.authRepository)
        )
    }
}
