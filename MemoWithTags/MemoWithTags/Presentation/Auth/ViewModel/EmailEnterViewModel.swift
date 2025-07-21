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
    @ObservationIgnored @Injected(\.authService) private var authService
    @ObservationIgnored @Injected(\.navigationState) private var navigation
    @ObservationIgnored @Injected(\.alertState) private var alert
    
    var isLoading = false
    
    func checkEmailValidity(email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func sendCode(email: String) async {
        guard !isLoading else { return }
        
        guard checkEmailValidity(email: email) else {
            alert.alert(error: SendCodeError.invalidEmail)
            return
        }
        
        isLoading = true
    
        let result = await authService.sendCode(email: email, type: navigation.current == .resetPasswordEmailEnter ? .ResetPassword : .Register)

        switch result {
        case .success:
            switch navigation.current {
            case .emailEnter:
                navigation.push(to: .emailVerification(email: email))
            case .resetPasswordEmailEnter:
                navigation.push(to: .resetPasswordEmailVerification(email: email))
            default: break
            }

        case .failure(let error):
            alert.alert(error: error)
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
