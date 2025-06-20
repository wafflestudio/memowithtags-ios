//
//  EmailVerificationViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI
import Factory

@MainActor
@Observable
final class EmailVerificationViewModel {
    @ObservationIgnored @Injected(\.authService) private var authService: AuthService
    
    var isLoading = false
    var notMatchCode = false
    var time = 300
    

    func sendCode(email: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        notMatchCode = false
        
        // 내비게이션 상태에 따라 이메일 타입 결정: resetPasswordEmailVerification이면 .ResetPassword, 그 외는 .Register
        let emailType: EmailType = {
            switch appState.navigation.current {
            case .resetPasswordEmailVerification(_):
                return .ResetPassword
            default:
                return .Register
            }
        }()
        
        let result = await authService.sendCode(email: email, type: emailType)
        
        switch result {
        case .success:
            time = 300
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    func verify(email: String, code: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        notMatchCode = false
        
        // 내비게이션 상태에 따라 이메일 타입 결정: resetPasswordEmailVerification이면 .ResetPassword, 그 외는 .Register
        let emailType: EmailType = {
            switch appState.navigation.current {
            case .resetPasswordEmailVerification(_):
                return .ResetPassword
            default:
                return .Register
            }
        }()
        
        let result = await useCases.authService.verifyCode(email: email, code: code, type: emailType)
        
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
            switch error {
            case .notMatchCode:
                notMatchCode = true
            default:
                appState.system.alert(error: error)
            }
        }
        
        isLoading = false
    }
}

@MainActor
extension Container {
    var emailVerificationViewModel: Factory<EmailVerificationViewModel> {
        self { @MainActor in EmailVerificationViewModel() }.cached
    }
}
