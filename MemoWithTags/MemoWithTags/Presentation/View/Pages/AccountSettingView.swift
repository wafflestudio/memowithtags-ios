//
//  AccountSettingView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/26/25.
//

import SwiftUI

struct AccountSettingView: View {
    @ObservedObject var viewModel: MainViewModel
    
    @State private var showWithdrawalSheet = false
    @State private var email = ""
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.backgroundGray
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.leading, 40)
                    } else {
                        HStack(spacing: 6) {
                            Text(viewModel.appState.user.userName ?? "")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.titleTextBlack)
                            
                            Text("#\(viewModel.appState.user.userNumber ?? 0)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.dateGray)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("닉네임 변경")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.titleTextBlack)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(Color.dateGray)
                        }
                        .background(Color.memoBackgroundWhite)
                        .onTapGesture {
                            viewModel.appState.navigation.push(to: .changeNickname)
                        }

                    }
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 17)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Text("이메일")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.titleTextBlack)
                        
                        Spacer()
                        
                        Text(viewModel.appState.user.userEmail ?? "")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color.dateGray)
                    }
                    
                    HStack {
                        Text("비밀번호 변경")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.titleTextBlack)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color.dateGray)
                    }
                    .background(Color.white)
                    .onTapGesture {
                        viewModel.appState.navigation.push(to: .changePassword)
                    }
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 17)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                HStack {
                    Text("로그아웃")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(hex: "#FF5151"))
                    Spacer()
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 17)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .onTapGesture {
                    Task {
                        await viewModel.logout()
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(hex: "#FF5151"))
                    
                    Text("회원 탈퇴")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(hex: "#FF5151"))
                    
                    Spacer()
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 17)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .onTapGesture {
                    showWithdrawalSheet = true
                }
                .padding(.top, 20)
                
            }
            .padding(.horizontal, 12)
            
        }
        .onAppear {
            Task {
                await viewModel.getUserInfo()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .regular))
                    .onTapGesture {
                        viewModel.appState.navigation.pop()
                    }
            }
            
            ToolbarItem(placement: .navigation) {
                Text("내 계정")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.titleTextBlack)
            }
        }
        .sheet(isPresented: $showWithdrawalSheet) {
            VStack(spacing: 20) {
                Text("회원을 탈퇴하시겠습니까?")
                    .font(.system(size: 20, weight: .medium))
                    .padding(.top, 20)
                
                Text("이메일을 입력해주세요.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.gray)
                
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
                
                Button {
                    //action
                    Task {
                        
                    }
                } label: {
                    Text("확인")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)

                }
                .background(email.isEmpty ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
                .cornerRadius(22)
                .padding(.top, 16)
                .disabled(email.isEmpty)
                
                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

