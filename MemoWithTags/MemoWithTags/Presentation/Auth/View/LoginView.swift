//
//  LoginView.swift
//  MemoWithTags
//
//  Created by 최진모 on 12/26/24.
//

import SwiftUI
import Factory

struct LoginView: View {
    @InjectedObservable(\.loginViewModel) private var viewModel: LoginViewModel
    @InjectedObservable(\.navigation) private var navigation: Navigation
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("Memo with")
                        .font(.pretendard(.semibold, size: 22))
                        .foregroundStyle(Color.basicText)
                    
                    DesignTagView(text: "Tags", fontSize: 19, backGroundColor: .titleTag) {}
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //login panel
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        //MARK: - 이메일 입력 필드
                        InputFieldView(text: $email, placeholder: "이메일", showCount: false, showAlert: false)
                        
                        //MARK: - 비밀번호 입력 필드
                        SecureInputFieldView(password: $password, placeholder: "비밀번호", showCondition: false)
                        
                        //MARK: - 확인 버튼
                        SubmitButtonView(text: "로그인", loading: viewModel.isLoading, disabled: email.isEmpty || password.isEmpty) {
                            Task {
                                await viewModel.login(email: email, password: password)
                            }
                        }
                        .padding(.top, 6)
                    }
                    
                    //MARK: - 아래 버튼들
                    HStack(spacing: 8) {
                        DesignTagView(text: "회원가입", fontSize: 13, backGroundColor: .TagColor.Red2.color) {
                            navigation.push(to: .emailEnter)
                        }
                        
                        Spacer()
                        
                        DesignTagView(text: "비밀번호 찾기", fontSize: 13, backGroundColor: .colorlessTag) {
                            navigation.push(to: .resetPasswordEmailEnter)
                        }
                    }
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 16)
                .background(Color.memoBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 12)
            .background(.clear)
            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)

        }
        .navigationBarBackButtonHidden()
    }
}
