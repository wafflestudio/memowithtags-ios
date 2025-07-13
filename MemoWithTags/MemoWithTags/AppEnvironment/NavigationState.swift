//
//  Navigation.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/21/25.
//

import Foundation
import SwiftUI
import Factory

enum Route: Hashable {
    case root
    case main
    case search
    
    //MARK: - 로그인
    case login
    
    //MARK: - 회원가입
    case emailEnter
    case emailVerification(email: String)
    case signup(email: String)
    case signupSuccess
    case nicknameSetting
  
    //MARK: - 비밀번호 찾기
    case resetPasswordEmailEnter
    case resetPasswordEmailVerification(email: String)
    case resetPassword(email: String)
    case resetPasswordSuccess
  
    //MARK: - 세팅
    case settings
    case accountSetting
    case tagSetting
    case tagDetailedSetting(tag: Tag)
    case changeNickname
    case changePassword
}

@MainActor
@Observable
final class NavigationState {
    var path = NavigationPath()
    var explicitStack: [Route] = []
    
    var current: Route {
        return explicitStack.last ?? .root
    }
    
    func push(to route: Route) {
        path.append(route)
        explicitStack.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
        if !explicitStack.isEmpty {
            explicitStack.removeLast()
        }
    }
    
    func reset() {
        Container.shared.mainViewModel.reset()
        path = NavigationPath()
        explicitStack = []
    }
}

extension Container {
    @MainActor
    var navigationState: Factory<NavigationState> {
        self { @MainActor in NavigationState() }.singleton
    }
}

