//
//  SignupSuccessViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/21/25.
//

import SwiftUI
import Factory

@MainActor
@Observable
final class SignupSuccessViewModel {
    @Injected(\.navigation) private var navigation: Navigation
    
    func start() {
        if let _ = KeyChainManager.shared.readAccessToken(),
           let _ = KeyChainManager.shared.readRefreshToken() {
            navigation.reset()
            navigation.push(to: .main)
        } else {
            navigation.reset()
            navigation.push(to: .login)
        }
    }
}

extension Container {
    @MainActor
    var signupSuccessViewModel: Factory<SignupSuccessViewModel> {
        self { @MainActor in SignupSuccessViewModel() }.cached
    }
}
