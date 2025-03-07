//
//  LoginView.swift
//  MemoWithTags
//
//  Created by 최진모 on 12/26/24.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        
        ZStack {
            Color.backgroundGray.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("Memo with")
                        .font(.pretendard(.semibold, size: 22))
                        .foregroundStyle(Color.titleTextBlack)
                    
                    DesignTagView(text: "Tags", fontSize: 19, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#E3E3E7", cornerRadius: 4) {}
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //login panel
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        //MARK: - 이메일 입력 필드
                        TextField (
                            "",
                            text: $email,
                            prompt:
                                Text("이메일")
                                .font(.pretendard(.regular, size: 16))
                                .foregroundStyle(Color(hex: "#94979F"))
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .font(.pretendard(.regular, size: 16))
                        .background(.white)
                        .overlay (
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "#181E2226"), lineWidth: 1)
                        )
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        
                        //MARK: - 비밀번호 입력 필드
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
                        
                        //MARK: - 확인 버튼
                        Button {
                            //action
                            Task {
                                await viewModel.login(email: email, password: password)
                            }

                        } label: {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Text("로그인")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .font(.pretendard(.semibold, size: 16))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)

                        }
                        .background(email.isEmpty || password.isEmpty || viewModel.isLoading ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
                        .cornerRadius(22)
                        .padding(.top, 6)
                        .disabled(email.isEmpty || password.isEmpty || viewModel.isLoading)
                    }
                    
                    //MARK: - 아래 버튼들
                    HStack(spacing: 8) {
                        DesignTagView(text: "회원가입", fontSize: 13, fontWeight: .regular, horizontalPadding: 6, verticalPadding: 2, backGroundColor: "#FFBDBD", cornerRadius: 4) {
                            viewModel.appState.navigation.push(to: .emailEnter)
                        }
                        
                        Spacer()
                        
                        DesignTagView(text: "비밀번호 찾기", fontSize: 13, fontWeight: .regular, horizontalPadding: 6, verticalPadding: 2, backGroundColor: "#F1F1F3", cornerRadius: 4) {
                            viewModel.appState.navigation.push(to: .resetPasswordEmailEnter)
                        }
                    }
                    
//                    Divider()
//                        .overlay {
//                            Text("다른 계정으로 로그인")
//                                .font(.pretendard(.medium, size: 12))
//                                .padding(.horizontal, 8)
//                                .foregroundStyle(Color.tabBarNotSelectecdIconGray)
//                                .background(Color.white)
//                        }
//                    
//                    //MARK: - 소셜 로그인 버튼들
//                    HStack(spacing: 18) {
//                        // 카카오 로그인 버튼
//                        Link(destination: URL(string: "https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=ed92cd34690fb718013b559ebd98353a&redirect_uri=http://ec2-43-201-64-202.ap-northeast-2.compute.amazonaws.com:8080/api/v1/auth/code/kakao")!) {
//                            Image(.kakaoIcon)
//                                .resizable()
//                                .frame(width: 40, height: 40)
//                        }
//                        
//                    }
                }
                .padding(.vertical, 18)
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
