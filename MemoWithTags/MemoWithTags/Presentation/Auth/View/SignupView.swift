//
//  SignupView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/5/25.
//

import SwiftUI
import Factory

struct SignupView: View {
    @InjectedObservable(\.signupViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    
    let email: String
    @State private var nickname: String = ""
    @State private var password: String = ""
    @State private var passwordRepeat: String = ""
    
    @State private var showBackAlert: Bool = false
    
    var body: some View {
        
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("이메일로 회원가입")
                        .font(.pretendard(.semibold, size: 21))
                        .foregroundStyle(Color.basicText)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //signup panel
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        //MARK: - 닉네임 입력 필드
                        InputFieldView(text: $nickname, placeholder: "닉네임", showCount: true, showAlert: nickname.count > 16)
                        
                        //MARK: - 비밀번호 입력 필드
                        SecureInputFieldView(password: $password, placeholder: "비밀번호", showCondition: true)
                        
                        //MARK: - 비밀번호 확인 필드
                        SecureInputFieldView(password: $passwordRepeat, placeholder: "비밀번호 확인", showCondition: false)
                    }
                    
                    //MARK: - 회원가입 버튼
                    SubmitButtonView(
                        text: "다음", loading: viewModel.isLoading, disabled: !(1...16 ~= nickname.count) || password.isEmpty || passwordRepeat.isEmpty
                    ) {
                        Task {
                            await viewModel.signup(nickname: nickname, email: email, password: password, passwordRepeat: passwordRepeat)
                        }
                    }
                    .padding(.top, 16)
                    
                    //MARK: - 안내 문구 및 링크
                    VStack(spacing: 12) {
                        Text("다음을 누르시면 이용약관과 개인정보처리방침에 동의한 것으로 간주됩니다.")
                            .font(.pretendard(.regular, size: 12))
                            .foregroundStyle(Color.basicText)
                            .multilineTextAlignment(.center)
                            .padding(.top, 12)

                        HStack(spacing: 16) {
                            Link(destination: URL(string: "https://wafflestudio.github.io/memowithtags-ios/service-term.html")!) {
                                Text("이용약관")
                                    .font(.pretendard(.regular, size: 14))
                                    .foregroundStyle(Color.blue)
                            }

                            Link(destination: URL(string: "https://wafflestudio.github.io/memowithtags-ios/privacy-policy.html")!) {
                                Text("개인정보처리방침")
                                    .font(.pretendard(.regular, size: 14))
                                    .foregroundStyle(Color.blue)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

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
                    .padding(.top, 24)
                }
                .padding(.top, 18)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(Color.memoBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal, 12)
            .background(.clear)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.checkPasswordValidity(password: password)
        }
        .alert("이전", isPresented: $showBackAlert) {
            Button("확인", role: .destructive) {
                navigation.switchTo(.auth)
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("로그인 화면으로 돌아가시겠습니까?")
        }
    }
}

