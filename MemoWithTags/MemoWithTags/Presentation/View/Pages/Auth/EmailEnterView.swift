//
//  EmailView.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/22/25.
//

import SwiftUI

struct EmailEnterView: View {
    @ObservedObject var viewModel: EmailEnterViewModel
    
    @State private var email: String = ""
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - 타이틀
                HStack(spacing: 4) {
                    Text(viewModel.appState.navigation.current == .emailEnter ? "이메일로 회원가입" : "비밀번호 찾기")
                        .font(.pretendard(.medium, size: 22))
                        .foregroundStyle(Color.basicText)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //login panel
                VStack(spacing: 0) {
                    //MARK: - 이메일 입력 필드
                    InputFieldView(text: $email, placeholder: "이메일", showCount: false, showAlert: false)
                    
                    //MARK: - 확인 버튼
                    SubmitButtonView(text: "다음", loading: viewModel.isLoading, disabled: email.isEmpty) {
                        Task {
                            await viewModel.sendCode(email: email)
                        }
                    }
                    .padding(.top, 16)
                    
                    //MARK: - 아래 버튼들
                    HStack(spacing: 8) {
                        DesignTagView(text: "이전", fontSize: 13, backGroundColor: .colorlessTag) {
                            viewModel.appState.navigation.pop()
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.TagColor.Red2.color)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.colorlessTag)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.colorlessTag)
                            .frame(width: 12, height: 24)
                    }
                    .padding(.top, 36)
                }
                .padding(.top, 18)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(Color.memoBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
            }
            .padding(.horizontal, 12)
            .background(.clear)

        }
        .navigationBarBackButtonHidden()
    }
}
