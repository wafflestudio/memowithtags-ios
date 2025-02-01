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
                //title
                HStack(spacing: 4) {
                    Text("Memo with")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.titleTextBlack)
                    
                    DesignTagView(text: "Tags", fontSize: 19, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#E3E3E7", cornerRadius: 4) {}
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //login panel
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
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
                    }
                    
                    VStack(spacing: 6) {
                        //로그인 버튼
                        Button {
                            //action
                            Task {
                                await viewModel.login(email: email, password: password)
                            }

                        } label: {
                            Text("로그인")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.vertical, 12)

                        }
                        .background(email.isEmpty || password.isEmpty ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
                        .cornerRadius(22)
                        .padding(.top, 16)
                        .disabled(email.isEmpty || password.isEmpty)
                        
                        Text("한 번 로그인하면 이 기기 외 다른 기기에서는 로그인이 불가능합니다!")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    
                    HStack(spacing: 8) {
                        DesignTagView(text: "회원가입", fontSize: 14, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#FFBDBD", cornerRadius: 4) {
                            viewModel.appState.navigation.push(to: .signup)
                        }
                        
                        Spacer()
                        
                        DesignTagView(text: "비밀번호 찾기", fontSize: 14, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#F1F1F3", cornerRadius: 4) {
                            viewModel.appState.navigation.push(to: .forgotPassword)
                        }
                    }
                    
                    Divider()
                        .overlay {
                            Text("다른 계정으로 로그인")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 8)
                                .foregroundStyle(Color.tabBarNotSelectecdIconGray)
                                .background(Color.white)
                        }
                    
                    HStack(spacing: 18) {
                        // 카카오 로그인 버튼
                        Link(destination: URL(string: "https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=ed92cd34690fb718013b559ebd98353a&redirect_uri=http://ec2-43-201-64-202.ap-northeast-2.compute.amazonaws.com:8080/api/v1/auth/code/kakao")!) {
                            Image(.kakaoIcon)
                                .resizable()
                                .frame(width: 40, height: 40)
                        }

                        // 네이버 로그인 버튼
                        Link(destination: URL(string: "https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=07oGdnrenHyLis9d_r7T&redirect_uri=http://ec2-43-201-64-202.ap-northeast-2.compute.amazonaws.com:8080/api/v1/auth/code/naver")!) {
                            Image(.naverIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                        }
                        
                        // 구글 로그인 버튼
                        Link(destination: URL(string: "https://accounts.google.com/o/oauth2/v2/auth?client_id=596067660858-dtgcrfdb30tinv7ga272vnv0v53a2o9c.apps.googleusercontent.com&redirect_uri=http://ec2-43-201-64-202.ap-northeast-2.compute.amazonaws.com:8080/api/v1/auth/code/google&response_type=code&scope=email%20profile")!) {
                            Image(.googleIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                        }
                        
                    }
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
