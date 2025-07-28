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

// MARK: - NavigationContext
enum NavigationContext {
    case splash
    case auth
    case main
}

@MainActor
@Observable
final class NavigationState {
    var activeContext: NavigationContext = .splash
    
    var authPath = NavigationPath()
    var mainPath = NavigationPath()
    
    var explicitStack: [Route] = [.root]
    
    var current: Route {
        return explicitStack.last ?? .root
    }
    
    func switchTo(_ context: NavigationContext) {
        reset(context: context)
        activeContext = context
    }
    
    func push(to route: Route) {
        explicitStack.append(route)
        switch activeContext {
        case .auth:
            authPath.append(route)
        case .main:
            mainPath.append(route)
        case .splash:
            break
        }
    }
    
    func pop() {
        if explicitStack.count > 1 { explicitStack.removeLast() }
        switch activeContext {
        case .auth:
            if !authPath.isEmpty { authPath.removeLast() }
        case .main:
            if !mainPath.isEmpty { mainPath.removeLast() }
        case .splash:
            break
        }
    }
    
    private func reset(context: NavigationContext? = nil) {
        explicitStack = []
        if let contextToReset = context {
            switch contextToReset {
            case .auth:
                authPath = NavigationPath()
                explicitStack = [.login]
            case .main:
                mainPath = NavigationPath()
                explicitStack = [.main]
            case .splash:
                explicitStack = [.root]
                break
            }
        } else {
            authPath = NavigationPath()
            mainPath = NavigationPath()
            explicitStack = [.root]
        }
    }
}

extension Container {
    @MainActor
    var navigationState: Factory<NavigationState> {
        self { @MainActor in NavigationState() }.singleton
    }
}

