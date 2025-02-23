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
    
    ///정규식으로 비밀번호 형식 검사
    func checkPasswordValidity(password: String) {
        let containsUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let containsLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let containsNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let containsSpecialCharacter = password.range(of: "[!@#$%^&*?_+=-]", options: .regularExpression) != nil
        
        isValidLength = password.count >= 8 && password.count <= 16
        isValidPasswordFormat = containsUppercase && containsLowercase && containsNumber && containsSpecialCharacter
    }
    
    func resetPassword(email: String, password: String, passwordRepeat: String) async {
        guard !isLoading else { return }
        
        checkPasswordValidity(password: password)
        
        guard isValidLength && isValidPasswordFormat else {
            appState.system.alert(error: RegisterError.invalidPassword)
            return
        }
        
        guard password == passwordRepeat else {
            appState.system.alert(error: RegisterError.passwordNotMatch)
            return
        }
        
        isLoading = true
        
        let result = await useCases.authService.resetPassword(email: email, newPassword: password)
        
        switch result {
        case .success:
            appState.navigation.push(to: .resetPasswordSuccess)
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
}
