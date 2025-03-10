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
                //MARK: - 기존 비밀번호 입력 필드
                SecureField (
                    "",
                    text: $currentPassword,
                    prompt:
                        Text("기존 비밀번호")
                        .font(.pretendard(.regular, size: 16))
                        .foregroundStyle(Color.placeholderGrayInWhiteBackground)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .font(.pretendard(.regular, size: 16))
                .background(.white)
                .overlay (
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.strokeGrayInWhiteBackground, lineWidth: 1)
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                
                //MARK: - 세 비밀번호 입력 필드
                VStack(alignment: .leading, spacing: 4) {
                    SecureField(
                        "",
                        text: $newPassword,
                        prompt: Text("새 비밀번호")
                            .font(.pretendard(.regular, size: 16))
                            .foregroundStyle(Color.placeholderGrayInWhiteBackground)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .font(.pretendard(.regular, size: 16))
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.strokeGrayInWhiteBackground, lineWidth: 1)
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
                                .foregroundStyle(viewModel.isValidLength ? Color.basicTextColor : Color.basicGray)
                            Text("최소 8자 ~ 최대 16자")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(viewModel.isValidLength ? Color.basicTextColor : Color.basicGray)
                        }
                        
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(viewModel.isValidPasswordFormat ? Color.basicTextColor : Color.basicGray)
                            Text("알파벳 대소문자, 숫자, 특수문자 포함")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(viewModel.isValidPasswordFormat ? Color.basicTextColor : Color.basicGray)
                        }
                    }
                    .padding(.horizontal, 6)
                }
                
                //MARK: - 새 비밀번호 확인 필드
                SecureField(
                    "",
                    text: $newPasswordRepeat,
                    prompt: Text("비밀번호 확인")
                        .font(.pretendard(.regular, size: 16))
                        .foregroundStyle(Color.placeholderGrayInWhiteBackground)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .font(.pretendard(.regular, size: 16))
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.strokeGrayInWhiteBackground, lineWidth: 1)
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            }
            
            Spacer()
            
            //MARK: - 확인 버튼
            Button {
                Task {
                    await viewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword, newPasswordRepeat: newPasswordRepeat)
                }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("완료")
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.pretendard(.semibold, size: 16))
                .foregroundStyle(.white)
                .padding(.vertical, 12)
            }
            .background(currentPassword.isEmpty || newPassword.isEmpty || newPasswordRepeat.isEmpty || viewModel.isLoading ? Color.searchBarBackgroundColor : Color.basicTextColor)
            .cornerRadius(22)
            .disabled(currentPassword.isEmpty || newPassword.isEmpty || newPasswordRepeat.isEmpty || viewModel.isLoading)

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
                    .font(.pretendard(.semibold, size: 18))
                    .foregroundStyle(Color.basicTextColor)
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
