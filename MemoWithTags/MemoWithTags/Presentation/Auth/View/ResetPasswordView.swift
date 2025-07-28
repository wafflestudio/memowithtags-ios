//
//  ResetPasswordView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/17/25.
//

import SwiftUI
import Factory

struct ResetPasswordView: View {
    @InjectedObservable(\.resetPasswordViewModel) var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    
    let email: String
    @State private var password: String = ""
    @State private var passwordRepeat: String = ""
    
    @State private var showBackAlert: Bool = false
    
    var body: some View {
        
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("비밀번호 재설정")
                        .font(.pretendard(.semibold, size: 21))
                        .foregroundStyle(Color.basicText)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //signup panel
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        //MARK: - 비밀번호 입력 필드
                        SecureInputFieldView(password: $password, placeholder: "비밀번호", showCondition: true)
                        
                        //MARK: - 비밀번호 확인 필드
                        SecureInputFieldView(password: $passwordRepeat, placeholder: "비밀번호 확인", showCondition: false)
                    }
                    
                    //MARK: - 확인 버튼
                    SubmitButtonView(text: "다음", loading: viewModel.isLoading, disabled: password.isEmpty || passwordRepeat.isEmpty) {
                        Task {
                            await viewModel.resetPassword(email: email, password: password, passwordRepeat: passwordRepeat)
                        }
                    }
                    .padding(.top, 16)
                    
                    //MARK: - 아래 버튼들
                    HStack(spacing: 8) {
                        DesignTagView(text: "이전", fontSize: 13, backGroundColor: .colorlessTag) {
                            showBackAlert = true
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.TagColor.Red2.color)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.TagColor.Red2.color)
                            .frame(width: 12, height: 24)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.TagColor.Red2.color)
                            .frame(width: 12, height: 24)
                    }
                    .padding(.top, 36)
                }
                .padding(.top, 18)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(Color.memoBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 12)
            .background(.clear)
            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
        }
        .navigationBarBackButtonHidden()
        .alert("이전", isPresented: $showBackAlert) {
            Button("확인", role: .destructive) {
                navigation.switchTo(.auth)
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("로그인 화면으로 돌아가시겠습니까?")
        }
        .onAppear {
            viewModel.checkPasswordValidity(password: password)
        }
    }
}
