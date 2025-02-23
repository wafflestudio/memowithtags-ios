//
//  SignupViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/2/25.
//

import Foundation

@MainActor
final class SignupViewModel: BaseViewModel, ObservableObject {
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
    
    func signup(nickname: String, email: String, password: String, passwordRepeat: String) async {
        checkPasswordValidity(password: password)
        let isPasswordSame = password == passwordRepeat
        
        guard !isLoading else { return }

        if nickname.count > 8 {
            appState.system.showAlert = true
            appState.system.errorMessage = "닉네임은 8자 이하입니다."
        } else if !isValidPasswordFormat || !isValidLength {
            appState.system.showAlert = true
            appState.system.errorMessage = RegisterError.invalidPassword.localizedDescription
        } else if !isPasswordSame {
            appState.system.showAlert = true
            appState.system.errorMessage = RegisterError.passwordNotMatch.localizedDescription
        } else {
            isLoading = true
            let result = await useCases.authService.register(email: email,
                                                             passsword: password,
                                                             nickname: nickname)
            
            switch result {
            case .success:
                appState.navigation.push(to: .emailVerification(email: email))
            case .failure(let error):
                appState.system.showAlert = true
                // 괄호 없이 localizedDescription 사용
                appState.system.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

