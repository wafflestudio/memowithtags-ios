//
//  ResetPasswordView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/17/25.
//

import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var viewModel: ResetPasswordViewModel
    
    let email: String
    let code: String
        
    @State private var password: String = ""
    @State private var passwordRepeat: String = ""
    
    var body: some View {
        
        ZStack {
            Color.backgroundGray.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //title
                HStack(spacing: 4) {
                    Text("비밀번호 재설정")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(Color.titleTextBlack)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //signup panel
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        // 비밀번호 입력 필드
                        VStack(alignment: .leading, spacing: 4) {
                            SecureField(
                                "",
                                text: $password,
                                prompt: Text("비밀번호")
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
                            .onChange(of: password) {
                                viewModel.checkPasswordValidity(password: password)
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
                            text: $passwordRepeat,
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
                    
                    //회원가입 버튼
                    Button {
                        //action
                        Task {
                            print(email, code, password, passwordRepeat)
                            await viewModel.resetPassword(email: email, password: password, passwordRepeat: passwordRepeat, code: code)
                        }
                    } label: {
                        Text("확인")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)

                    }
                    .background(password.isEmpty || passwordRepeat.isEmpty ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
                    .cornerRadius(22)
                    .padding(.top, 16)
                    .disabled(password.isEmpty || passwordRepeat.isEmpty)
                    
                    HStack(spacing: 8) {
                        DesignTagView(text: "이전", fontSize: 14, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#E3E3E7", cornerRadius: 4) {
                            viewModel.appState.navigation.pop()
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.highlightRed)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.highlightRed)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.highlightRed)
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
        .onAppear {
            viewModel.isValidPasswordFormat = false
            viewModel.isValidLength = false
        }
    }
}

struct ResetPasswordSuccessView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Color.backgroundGray.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //title
                HStack(spacing: 4) {
                    Text("비밀번호가 재설정되었습니다!")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(Color.titleTextBlack)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //auth panel
                VStack(spacing: 0) {
                    //환영글
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            HStack(spacing: 3) {
                                Text("Memo with")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color.titleTextBlack)
                                
                                DesignTagView(text: "Tags", fontSize: 14, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#E3E3E7", cornerRadius: 4) {}
                            }
                            Text("를 통해")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.titleTextBlack)
                        }
                        Text("복잡한 메모들을 간단하고 효율적으로 정리해보세요!")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.titleTextBlack)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    
                    //시작버튼
                    Button {
                        //action
                        viewModel.start()
                    } label: {
                        Text("로그인하러 가기")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                    }
                    .background(Color(hex: "#FF9C9C"))
                    .cornerRadius(22)
                    .padding(.top, 16)
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

extension ResetPasswordSuccessView {
    @MainActor
    final class ViewModel: BaseViewModel, ObservableObject {
        func start() {
            appState.navigation.reset()
            appState.navigation.push(to: .login)
        }
    }
}
