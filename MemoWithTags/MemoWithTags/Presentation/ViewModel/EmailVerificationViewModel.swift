//
//  EmailVerificationViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI

@MainActor
final class EmailVerificationViewModel: BaseViewModel, ObservableObject {
    @Published var isLoading = false
    
    func verify(email: String, code: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        // AuthService의 verifyCode 메서드를 호출
        let result = await useCases.authService.verifyCode(email: email, code: code)
        
        switch result {
        case .success:
            // 인증에 성공하면 회원가입 화면으로 이동
            appState.navigation.push(to: .signup)
        case .failure(let error):
            // 인증에 실패하면 Alert 표시 및 에러 메시지 설정
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
