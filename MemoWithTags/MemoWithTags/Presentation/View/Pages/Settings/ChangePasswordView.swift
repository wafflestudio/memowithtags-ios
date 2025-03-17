//
//  ChangePasswordView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/27/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var newPasswordRepeat: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            //MARK: - navigation bar
            HStack(spacing: 0) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19))
                    .foregroundStyle(Color.soft)
                    .padding(12) // 터치 영역을 확장하기 위해 패딩 추가
                    .contentShape(Rectangle()) // 전체 영역을 터치 가능 영역으로 지정
                    .onTapGesture {
                        viewModel.appState.navigation.pop()
                    }
                
                Text("비밀번호 변경")
                    .font(.pretendard(.semibold, size: 18))
                    .foregroundStyle(Color.basicText)
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            //MARK: -
            
            VStack(spacing: 10) {
                SecureInputFieldView(password: $currentPassword, placeholder: "기존 비밀번호", showCondition: false)
            
                SecureInputFieldView(password: $newPassword, placeholder: "새 비밀번호", showCondition: true)
                SecureInputFieldView(password: $newPasswordRepeat, placeholder: "비밀번호 확인", showCondition: false)
            }
            
            Spacer()
            
            SubmitButtonView(
                text: "완료", loading: viewModel.isLoading, disabled: currentPassword.isEmpty || newPassword.isEmpty || newPasswordRepeat.isEmpty
            ) {
                Task {
                    await viewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword, newPasswordRepeat: newPasswordRepeat)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
        .background(Color.memoBackground)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.checkPasswordValidity(password: newPassword)
        }
    }
}

extension ChangePasswordView {
    @MainActor
    final class ViewModel: BaseViewModel, ObservableObject {
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
        
        func changePassword(currentPassword: String, newPassword: String, newPasswordRepeat: String) async {
            guard !isLoading else { return }
            
            checkPasswordValidity(password: newPassword)
            
            guard isValidLength && isValidPasswordFormat else {
                appState.system.alert(error: ChangePasswordError.invalidPassword)
                return
            }
            
            guard newPassword == newPasswordRepeat else {
                appState.system.alert(error: ChangePasswordError.passwordNotMatch)
                return
            }
            
            isLoading = true
            
            let result = await useCases.userService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            
            switch result {
            case .success:
                appState.navigation.pop()
            case .failure(let error):
                appState.system.alert(error: error)
            }
            
            isLoading = false
        }
    }
}
