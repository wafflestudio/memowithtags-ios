//
//  Untitled.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/9/25.
//

import SwiftUI

enum Route: Hashable {
    case root
    case main
    case search
    
    //MARK: - 로그인
    case login
    
    //MARK: - 회원가입
    case emailEnter
    case emailVerification(email: String)
    case signup
    case signupSuccess
    case nicknameSetting
    
    //MARK: - 비밀번호 찾기
    case resetPasswordEmailEnter
    case resetPasswordEmailVerification(email: String)
    case resetPassword(email: String, code: String)
    case resetPasswordSuccess
    
    //MARK: - 세팅
    case settings
    case accountSetting
    case changeNickname
    case changePassword
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
