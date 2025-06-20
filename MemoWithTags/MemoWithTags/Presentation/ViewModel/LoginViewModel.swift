//
//  LoginViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 12/26/24.
//

import SwiftUI
import Factory

@MainActor
@Observable
final class LoginViewModel {
    @ObservationIgnored @Injected(\.authService) private var authService: AuthService
    
    var isLoading = false
    
    ///정규식으로 이메일 형식 검사
    func checkEmailValidity(email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func login(email: String, password: String) async {
        guard !isLoading else { return }
        
        guard checkEmailValidity(email: email) else {
            appState.system.alert(error: LoginError.invalidEmail)
            return
        }
        
        isLoading = true
        
        let result = await authService.login(email: email, password: password)

        switch result {
        case .success:
            appState.user.isLoggedIn = true
            appState.navigation.push(to: .main)
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
}

extension Container {
    @MainActor
    var loginViewModel: Factory<LoginViewModel> {
        self { @MainActor in LoginViewModel() }.cached
    }
}
