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
    
    func sendEmailCode(email: String) async {
        let isValidEmail = checkEmailValidity(email: email)
        
        guard !isLoading else { return }
        
        guard isValidEmail else {
            return
        }
        
        isLoading = true
    }
}
