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
        let result = await useCases.emailVerificationUseCase.execute(email: email, code: code)

        switch result {
        case .success:
            appState.navigation.push(to: .signupSuccess)
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription()
        }
        isLoading = false
    }
}
