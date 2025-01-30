//
//  Untitled.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/9/25.
//

import SwiftUI

enum Route: Hashable {
    //page 설정
    case root
    case main
    case login
    case signup
    case emailVerification(email: String)
    case signupSuccess
    case forgotPassword
    case forgotPasswordEmailVerification(email: String)
    case resetPassword(email: String, code: String)
    case resetPasswordSuccess
    case nicknameSetting
    case settings
    case accountSetting
    case changeNickname
    case changePassword
    case search
    case memoEditor(namespace: Namespace.ID, id: String)
}

@MainActor
final class NavigationState: ObservableObject {
    @Published var path = NavigationPath()
    // path는 push, pop, count 기능만 지원한다
    // 따라서 현재 Page가 어떤 Page인지 알기 위해 explicit한 stack이 필요하다.
    var explicitStack: [Route] = []
    
    // 현재 활성화된 Route를 반환하는 계산 프로퍼티
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
        explicitStack.removeLast()
    }
    
    func reset() {
        path.removeLast(path.count)
        explicitStack.removeLast(explicitStack.count)
    }
}
