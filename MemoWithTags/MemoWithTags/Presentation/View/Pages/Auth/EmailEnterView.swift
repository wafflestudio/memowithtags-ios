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
            Color.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                
                //MARK: - 타이틀
                HStack(spacing: 4) {
                    Text(viewModel.appState.navigation.current == .emailEnter ? "이메일로 회원가입" : "비밀번호 찾기")
                        .font(.pretendard(.medium, size: 22))
                        .foregroundStyle(Color.basicTextColor)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //login panel
                VStack(spacing: 0) {
                    //MARK: - 이메일 입력 필드
                    TextField (
                        "",
                        text: $email,
                        prompt:
                            Text("이메일")
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
                    
                    //MARK: - 확인 버튼
                    Button {
                        //action
                        Task {
                            await viewModel.sendCode(email: email)
                        }
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("다음")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .font(.pretendard(.regular, size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                    }
                    .background(email.isEmpty || viewModel.isLoading ? Color.searchBarBackgroundColor : Color.basicTextColor)
                    .cornerRadius(22)
                    .padding(.top, 16)
                    .disabled(email.isEmpty || viewModel.isLoading)
                    
                    //MARK: - 아래 버튼들
                    HStack(spacing: 8) {
                        DesignTagView(text: "이전", fontSize: 13, fontWeight: .regular, horizontalPadding: 6, verticalPadding: 2, backGroundColor: "#E3E3E7", cornerRadius: 4) {
                            viewModel.appState.navigation.pop()
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.textRed)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.backgroundColor)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.backgroundColor)
                            .frame(width: 12, height: 24)
                        
                    }
                    .padding(.top, 36)
                }
                .padding(.top, 18)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
            }
            .padding(.horizontal, 12)
            .background(.clear)

        }
        .navigationBarBackButtonHidden()
    }
}
