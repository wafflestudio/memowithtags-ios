//
//  ResetPasswordViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/17/25.
//

import Foundation

@MainActor
final class ResetPasswordViewModel: BaseViewModel, ObservableObject {
    @Published var isLoading = false
    
    @Published var isValidLength: Bool = false
    @Published var isValidPasswordFormat: Bool = false
    
    /// 정규식으로 비밀번호 형식 검사
    func checkPasswordValidity(password: String) {
        isValidLength = password.count >= 8 && password.count <= 16
        let containsUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let containsLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let containsNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let containsSpecialCharacter = password.range(of: "[!@#$%^&*?_+=-]", options: .regularExpression) != nil
        
        isValidPasswordFormat = containsUppercase && containsLowercase && containsNumber && containsSpecialCharacter
    }
    
    func resetPassword(email: String, password: String, passwordRepeat: String, code: String) async {
        checkPasswordValidity(password: password)
        let isPasswordSame = password == passwordRepeat
        
        guard !isLoading else { return }
        
        if !isValidLength || !isValidPasswordFormat {
            appState.system.showAlert = true
            // 괄호 없는 localizedDescription
            appState.system.errorMessage = ResetPasswordError.invalidPassword.localizedDescription
        } else if !isPasswordSame {
            appState.system.showAlert = true
            appState.system.errorMessage = ResetPasswordError.passwordNotMatch.localizedDescription
        } else {
            isLoading = true
            
            let result = await useCases.authService.resetPassword(email: email, newPassword: password)
            
            switch result {
            case .success:
                appState.navigation.push(to: .resetPasswordSuccess)
            case .failure(let error):
                appState.system.showAlert = true
                appState.system.errorMessage = error.localizedDescription
                appState.navigation.pop()
            }
            
            isLoading = false
        }
    }
}

