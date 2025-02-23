//
//  EmailEnterViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/22/25.
//

import SwiftUI

@MainActor
final class EmailEnterViewModel: BaseViewModel, ObservableObject {
    @Published var isLoading = false
    
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
    
        let result = await useCases.authService.sendCode(email: email)

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
        
        isLoading = true
    }
}
