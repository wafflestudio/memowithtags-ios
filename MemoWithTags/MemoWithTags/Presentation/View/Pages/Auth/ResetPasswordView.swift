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
    @State private var password: String = ""
    @State private var passwordRepeat: String = ""
    
    var body: some View {
        
        ZStack {
            Color.backgroundGray.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("비밀번호 재설정")
                        .font(.pretendard(.semibold, size: 21))
                        .foregroundStyle(Color.titleTextBlack)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //signup panel
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        //MARK: - 비밀번호 입력 필드
                        VStack(alignment: .leading, spacing: 4) {
                            SecureField(
                                "",
                                text: $password,
                                prompt: Text("비밀번호")
                                    .font(.pretendard(.regular, size: 16))
                                    .foregroundStyle(Color(hex: "#94979F"))
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .font(.pretendard(.regular, size: 16))
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
                                        .font(.pretendard(.regular, size: 12))
                                        .foregroundStyle(viewModel.isValidLength ? Color.titleTextBlack : Color.dateGray)
                                    Text("최소 8자 ~ 최대 16자")
                                        .font(.pretendard(.regular, size: 12))
                                        .foregroundStyle(viewModel.isValidLength ? Color.titleTextBlack : Color.dateGray)
                                }
                                
                                HStack {
                                    Image(systemName: "checkmark")
                                        .font(.pretendard(.regular, size: 12))
                                        .foregroundStyle(viewModel.isValidPasswordFormat ? Color.titleTextBlack : Color.dateGray)
                                    Text("알파벳 대소문자, 숫자, 특수문자 포함")
                                        .font(.pretendard(.regular, size: 12))
                                        .foregroundStyle(viewModel.isValidPasswordFormat ? Color.titleTextBlack : Color.dateGray)
                                }
                            }
                            .padding(.horizontal, 6)
                        }
                        
                        //MARK: - 비밀번호 확인 필드
                        SecureField(
                            "",
                            text: $passwordRepeat,
                            prompt: Text("비밀번호 확인")
                                .font(.pretendard(.regular, size: 16))
                                .foregroundStyle(Color(hex: "#94979F"))
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .font(.pretendard(.regular, size: 16))
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "#181E2226"), lineWidth: 1)
                        )
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                    }
                    
                    //MARK: - 확인 버튼
                    Button {
                        //action
                        Task {
                            await viewModel.resetPassword(email: email, password: password, passwordRepeat: passwordRepeat)
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
                        .font(.pretendard(.semibold, size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)

                    }
                    .background(password.isEmpty || passwordRepeat.isEmpty || viewModel.isLoading ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
                    .cornerRadius(22)
                    .padding(.top, 16)
                    .disabled(password.isEmpty || passwordRepeat.isEmpty || viewModel.isLoading)
                    
                    //MARK: - 아래 버튼들
                    HStack(spacing: 8) {
                        DesignTagView(text: "이전", fontSize: 13, fontWeight: .regular, horizontalPadding: 6, verticalPadding: 2, backGroundColor: "#E3E3E7", cornerRadius: 4) {
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
            viewModel.checkPasswordValidity(password: password)
        }
    }
}
