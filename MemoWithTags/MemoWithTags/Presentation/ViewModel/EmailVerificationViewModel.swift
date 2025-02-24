//
//  EmailVerificationViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI

@MainActor
final class EmailVerificationViewModel: BaseViewModel, ObservableObject {
    @Published var isLoading = false
    
    func verify(email: String, code: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await useCases.authService.verifyCode(email: email, code: code)

        switch result {
        case .success:
            switch appState.navigation.current {
            case .emailVerification:
                appState.navigation.push(to: .signup(email: email))
            case .resetPasswordEmailVerification:
                appState.navigation.push(to: .resetPassword(email: email))
            default: break
            }
            
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
}
