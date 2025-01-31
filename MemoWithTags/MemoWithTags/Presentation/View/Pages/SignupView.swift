//
//  SignupView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/5/25.
//

import SwiftUI

struct SignupView: View {
    @ObservedObject var viewModel: SignupViewModel
    
    @State private var nickname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordRepeat: String = ""
    
    var body: some View {
        
        ZStack {
            Color.backgroundGray.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //title
                HStack(spacing: 4) {
                    Text("이메일로 회원가입")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(Color.titleTextBlack)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //signup panel
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        VStack(spacing: 4) {
                            // 닉네임 입력 필드
                            TextField (
                                "",
                                text: $nickname,
                                prompt: Text("닉네임")
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
                            
                            //조건 표시
                            HStack {
                                Spacer()
                                Text("\(nickname.count)/8")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(nickname.count > 8 ? Color.red : Color.dateGray)
                                    .padding(.horizontal, 6)
                            }
                        }
                        
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
                            .onChange(of: password) { _, newPassword in
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
                            await viewModel.signup(nickname: nickname, email: email, password: password, passwordRepeat: passwordRepeat)
                        }
                    } label: {
                        Text("다음")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)

                    }
                    .background(nickname.isEmpty || email.isEmpty || password.isEmpty || passwordRepeat.isEmpty ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
                    .cornerRadius(22)
                    .padding(.top, 16)
                    .disabled(nickname.isEmpty || email.isEmpty || password.isEmpty || passwordRepeat.isEmpty)
                    
                    HStack(spacing: 8) {
                        DesignTagView(text: "로그인", fontSize: 14, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#F1F1F3", cornerRadius: 4) {
                            viewModel.appState.navigation.pop()
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#FFBDBD"))
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
        .onAppear {
            viewModel.isValidPasswordFormat = false
            viewModel.isValidLength = false
        }
    }
}

