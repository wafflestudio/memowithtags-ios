//
//  ForgotPasswordView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/15/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var email: String = ""
    
    var body: some View {
        ZStack {
            Color.backgroundGray.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                
                HStack(spacing: 4) {
                    Text("비밀번호 찾기")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(Color.titleTextBlack)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //login panel
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        Text("가입된 이메일을 입력해주세요.")
                            .padding(.vertical, 8)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.titleTextBlack)
                        
                        //이메일 입력 필드
                        TextField (
                            "",
                            text: $email,
                            prompt:
                                Text("이메일")
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
                    }
                    
                    //확인 버튼
                    Button {
                        //action
                        Task {
                            await viewModel.sendEmailCode(email: email)
                        }

                    } label: {
                        Text("인증코드 발송")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)

                    }
                    .background(email.isEmpty ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
                    .cornerRadius(22)
                    .padding(.top, 16)
                    .disabled(email.isEmpty)
                    
                    HStack(spacing: 8) {
                        DesignTagView(text: "이전", fontSize: 14, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#E3E3E7", cornerRadius: 4) {
                            viewModel.appState.navigation.pop()
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.highlightRed)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F1F1F3"))
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F1F1F3"))
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F1F1F3"))
                            .frame(width: 12, height: 24)
                    }
                    .padding(.top, 36)
                }
                .padding(.top, 18)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 12)
            .background(.clear)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)

        }
        .navigationBarBackButtonHidden()
    }
}

extension ForgotPasswordView {
    @MainActor
    final class ViewModel: BaseViewModel, ObservableObject {
        @Published var isLoading = false
        
        func checkEmailValidity(email: String) -> Bool {
            let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailPredicate.evaluate(with: email)
        }
        
        func sendEmailCode(email: String) async {
            guard !isLoading else { return }
            
            if !checkEmailValidity(email: email) {
                appState.system.showAlert = true
                appState.system.errorMessage = ForgotPasswordError.invalidEmail.localizedDescription()
            } else {
                isLoading = true
                
                let result = await useCases.forgotPasswordUseCase.execute(email: email)
                
                switch result {
                case .success:
                    appState.navigation.push(to: .forgotPasswordEmailVerification(email: email))
                case .failure(let error):
                    appState.system.showAlert = true
                    appState.system.errorMessage = error.localizedDescription()
                }
                
                isLoading = false
            }
        }
    }
}

struct ForgotPasswordEmailVerificationView: View {
    @ObservedObject var viewModel: ViewModel
    
    let email: String

    @State private var code: String = ""
    
    var body: some View {
        
        ZStack {
            Color.backgroundGray.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //title
                HStack(spacing: 4) {
                    Text("비밀번호를 잊어버렸나요?")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(Color.titleTextBlack)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //auth panel
                VStack(spacing: 0) {
                    Text("이메일로 발송된 인증번호를 입력해주세요.")
                        .padding(.vertical, 8)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.titleTextBlack)
                    
                    // 인증 코드 입력란
                    SeparatedTextField(length: 6, value: $code)
                        .padding(.top, 8)
                    
                    Button {
                        //action
                        viewModel.next(email: email, code: code)
                    } label: {
                        Text("다음")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)

                    }
                    .background(code.count < 6 ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
                    .cornerRadius(22)
                    .padding(.top, 16)
                    .disabled(code.count < 6)
                    
                    HStack(spacing: 8) {
                        DesignTagView(text: "이전", fontSize: 14, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#E3E3E7", cornerRadius: 4) {
                            viewModel.back()
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.highlightRed)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.highlightRed)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F1F1F3"))
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F1F1F3"))
                            .frame(width: 12, height: 24)
                        
                    }
                    .padding(.top, 36)
                }
                .padding(.top, 18)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 12)
            .background(.clear)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)

        }
        .navigationBarBackButtonHidden()
        
    }
}

extension ForgotPasswordEmailVerificationView {
    @MainActor
    final class ViewModel: BaseViewModel, ObservableObject {
        func next(email: String, code: String) {
            appState.navigation.push(to: .resetPassword(email: email, code: code))
        }
        func back() {
            appState.navigation.pop()
        }
    }
}
