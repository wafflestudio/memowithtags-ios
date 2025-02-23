//
//  LoginViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 12/26/24.
//

import Foundation

@MainActor
final class LoginViewModel: BaseViewModel, ObservableObject {
    @Published var isLoading = false
    
    /// 정규식으로 이메일 형식 검사
    func checkEmailValidity(email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func login(email: String, password: String) async {
        // 이메일 형식 검증
        if !checkEmailValidity(email: email) {
            appState.system.showAlert = true
            appState.system.errorMessage = LoginError.invalidEmail.localizedDescription
            return
        }
        
        guard !isLoading else { return }
        isLoading = true
        
        let result = await useCases.authService.login(email: email, password: password)

        switch result {
        case .success:
            appState.user.isLoggedIn = true
            appState.navigation.push(to: .main)
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

