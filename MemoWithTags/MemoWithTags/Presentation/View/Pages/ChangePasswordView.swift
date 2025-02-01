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
            VStack(spacing: 10) {
                SecureField (
                    "",
                    text: $currentPassword,
                    prompt:
                        Text("기존 비밀번호")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(hex: "#94979F"))
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .font(.system(size: 16, weight: .regular))
                .background(.white)
                .overlay (
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "#181E2226"), lineWidth: 1)
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                
                // 비밀번호 입력 필드
                VStack(alignment: .leading, spacing: 4) {
                    SecureField(
                        "",
                        text: $newPassword,
                        prompt: Text("새 비밀번호")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color(hex: "#94979F"))
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .font(.system(size: 16, weight: .regular))
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#181E2226"), lineWidth: 1)
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .onChange(of: newPassword) {
                        viewModel.checkPasswordValidity(password: newPassword)
                    }
                    
                    //조건 표시
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(viewModel.isValidLength ? Color.titleTextBlack : Color.dateGray)
                            Text("최소 8자 ~ 최대 16자")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(viewModel.isValidLength ? Color.titleTextBlack : Color.dateGray)
                        }
                        
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(viewModel.isValidPasswordFormat ? Color.titleTextBlack : Color.dateGray)
                            Text("알파벳 대소문자, 숫자, 특수문자 포함")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(viewModel.isValidPasswordFormat ? Color.titleTextBlack : Color.dateGray)
                        }
                    }
                    .padding(.horizontal, 6)
                }
                
                //비밀번호 확인 필드
                SecureField(
                    "",
                    text: $newPasswordRepeat,
                    prompt: Text("비밀번호 확인")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(hex: "#94979F"))
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .font(.system(size: 16, weight: .regular))
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "#181E2226"), lineWidth: 1)
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            }
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword, newPasswordRepeat: newPasswordRepeat)
                }
            } label: {
                Text("완료")
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 12)
                
            }
            .background(currentPassword.isEmpty || newPassword.isEmpty || newPasswordRepeat.isEmpty ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
            .cornerRadius(22)
            .disabled(currentPassword.isEmpty || newPassword.isEmpty || newPasswordRepeat.isEmpty)

        }
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .regular))
                    .onTapGesture {
                        viewModel.appState.navigation.pop()
                    }
            }
            
            ToolbarItem(placement: .navigation) {
                Text("비밀번호 변경")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.titleTextBlack)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.isValidPasswordFormat = false
            viewModel.isValidLength = false
        }
    }
}

extension ChangePasswordView {
    @MainActor
    final class ViewModel: BaseViewModel, ObservableObject {
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
        
        func changePassword(currentPassword: String, newPassword: String, newPasswordRepeat: String) async {
            checkPasswordValidity(password: newPassword)
            let isPasswordSame = newPassword == newPasswordRepeat
            
            if !isValidPasswordFormat || !isValidLength {
                appState.system.showAlert = true
                appState.system.errorMessage = ChangePasswordError.invalidPassword.localizedDescription()
            } else if !isPasswordSame {
                appState.system.showAlert = true
                appState.system.errorMessage = ChangePasswordError.passwordNotMatch.localizedDescription()
            } else {
                let result = await useCases.changePasswordUseCase.execute(currentPassword: currentPassword, newPassword: newPassword)
                
                switch result {
                case .success:
                    appState.navigation.pop()
                case .failure(let error):
                    appState.system.showAlert = true
                    appState.system.errorMessage = error.localizedDescription()
                }
            }
        }
    }
}
