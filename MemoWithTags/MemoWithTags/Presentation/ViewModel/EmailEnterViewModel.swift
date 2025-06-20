//
//  EmailEnterViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/22/25.
//

import SwiftUI
import Factory

@MainActor
@Observable
final class EmailEnterViewModel {
    @ObservationIgnored @Injected(\.authService) private var authService: AuthService
    
    var isLoading = false
    
    func checkEmailValidity(email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func sendCode(email: String) async {
        guard !isLoading else { return }
        
        guard checkEmailValidity(email: email) else {
            appState.system.alert(error: SendCodeError.invalidEmail)
            return
        }
        
        isLoading = true
        
        // 내비게이션 상태에 따라 이메일 타입 결정: 기본은 회원가입(.Register), 비밀번호 재설정이면 .ResetPassword
        let emailType: EmailType = appState.navigation.current == .resetPasswordEmailEnter ? .ResetPassword : .Register
    
        let result = await authService.sendCode(email: email, type: emailType)

        switch result {
        case .success:
            switch appState.navigation.current {
            case .emailEnter:
                appState.navigation.push(to: .emailVerification(email: email))
            case .resetPasswordEmailEnter:
                appState.navigation.push(to: .resetPasswordEmailVerification(email: email))
            default: break
            }

        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
}

extension Container {
    @MainActor
    var emailEnterViewModel: Factory<EmailEnterViewModel> {
        self { @MainActor in EmailEnterViewModel() }.cached
    }
}
