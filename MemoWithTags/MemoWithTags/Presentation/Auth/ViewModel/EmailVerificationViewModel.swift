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
    @ObservationIgnored @Injected(\.authService) private var authService
    @ObservationIgnored @Injected(\.navigationState) private var navigation
    @ObservationIgnored @Injected(\.alertState) private var alert
    
    var isLoading = false
    var notMatchCode = false
    var time = 300
    
    func sendCode(email: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        notMatchCode = false
        
        let emailType: EmailType = {
            switch navigation.current {
            case .resetPasswordEmailVerification:
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
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    func verify(email: String, code: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        notMatchCode = false
        
        let emailType: EmailType = {
            switch navigation.current {
            case .resetPasswordEmailVerification:
                return .ResetPassword
            default:
                return .Register
            }
        }()
        
        let result = await authService.verifyCode(email: email, code: code, type: emailType)
        
        switch result {
        case .success:
            switch navigation.current {
            case .emailVerification:
                navigation.push(to: .signup(email: email))
            case .resetPasswordEmailVerification:
                navigation.push(to: .resetPassword(email: email))
            default: break
            }
        case .failure(let error):
            switch error {
            case .notMatchCode:
                notMatchCode = true
            default:
                alert.alert(error: error)
            }
        }
        
        isLoading = false
    }
}

extension Container {
    @MainActor
    var emailVerificationViewModel: Factory<EmailVerificationViewModel> {
        self { @MainActor in EmailVerificationViewModel() }.cached
    }
}
