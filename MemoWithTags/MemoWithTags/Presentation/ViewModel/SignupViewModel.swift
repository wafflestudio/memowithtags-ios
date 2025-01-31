//
//  SignupViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/2/25.
//

import Foundation

@MainActor
final class SignupViewModel: BaseViewModel, ObservableObject {
    @Published var isValidLength: Bool = false
    @Published var isValidPasswordFormat: Bool = false
    
    ///정규식으로 비밀번호 형식 검사
    func checkPasswordValidity(password: String) {
        isValidLength = password.count >= 8 && password.count <= 16
        let containsUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let containsLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let containsNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let containsSpecialCharacter = password.range(of: "[!@#$%^&*?_+=-]", options: .regularExpression) != nil
        
        isValidPasswordFormat = containsUppercase && containsLowercase && containsNumber && containsSpecialCharacter
    }
    
    ///정규식으로 이메일 형식 검사
    func checkEmailValidity(email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func signup(nickname: String, email: String, password: String, passwordRepeat: String) async {
        let isEmailValid = checkEmailValidity(email: email)
        checkPasswordValidity(password: password)
        let isPasswordSame = password == passwordRepeat
        
        if nickname.count > 8 {
            appState.system.showAlert = true
            appState.system.errorMessage = "닉네임은 8자 이하입니다."
        } else if !isEmailValid {
            appState.system.showAlert = true
            appState.system.errorMessage = RegisterError.invalidEmail.localizedDescription()
        } else if !isValidPasswordFormat || !isValidLength {
            appState.system.showAlert = true
            appState.system.errorMessage = RegisterError.invalidPassword.localizedDescription()
        } else if !isPasswordSame {
            appState.system.showAlert = true
            appState.system.errorMessage = RegisterError.passwordNotMatch.localizedDescription()
        } else {
            let result = await useCases.signupUseCase.execute(nickname: nickname, email: email, password: password)
            
            switch result {
            case .success:
                appState.navigation.push(to: .emailVerification(email: email))
            case .failure(let error):
                appState.system.showAlert = true
                appState.system.errorMessage = error.localizedDescription()
            }
        }
    }
}
