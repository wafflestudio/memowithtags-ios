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
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //MARK: - navigation bar
                
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19))
                        .foregroundStyle(Color.soft)
                        .padding(12) // 터치 영역을 확장하기 위해 패딩 추가
                        .contentShape(Rectangle()) // 전체 영역을 터치 가능 영역으로 지정
                        .onTapGesture {
                            viewModel.appState.navigation.pop()
                        }
                    
                    Text("내 계정")
                        .font(.pretendard(.semibold, size: 18))
                        .foregroundStyle(Color.basicText)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                
                //MARK: -
                VStack(spacing: 12) {
                 
                    VStack(alignment: .leading, spacing: 12) {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.leading, 40)
                        } else {
                            HStack(spacing: 6) {
                                Text(viewModel.appState.user.userName ?? "")
                                    .font(.pretendard(.semibold, size: 16))
                                    .foregroundStyle(Color.basicText)
                                
                                Text("#\(viewModel.appState.user.userNumber ?? 0)")
                                    .font(.pretendard(.regular, size: 12))
                                    .foregroundStyle(Color.grayText)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text("닉네임 변경")
                                    .font(.pretendard(.regular, size: 14))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.pretendard(.regular, size: 14))
                                    .foregroundStyle(Color.soft)
                            }
                            .background(Color.memoBackground)
                            .onTapGesture {
                                viewModel.appState.navigation.push(to: .changeNickname)
                            }

                        }
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Text("이메일")
                                .font(.pretendard(.regular, size: 14))
                                .foregroundStyle(Color.basicText)
                            
                            Spacer()
                            
                            Text(viewModel.appState.user.userEmail ?? "")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                        }
                        
                        if !viewModel.appState.user.isSocial {
                            HStack {
                                Text("비밀번호 변경")
                                    .font(.pretendard(.regular, size: 14))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(Color.soft)
                            }
                            .background(Color.memoBackground)
                            .onTapGesture {
                                viewModel.appState.navigation.push(to: .changePassword)
                            }
                        }
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    HStack {
                        Text("로그아웃")
                            .font(.pretendard(.regular, size: 14))
                            .foregroundStyle(Color.redText)
                        Spacer()
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
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
                            .foregroundStyle(Color.redText)
                        
                        Text("회원 탈퇴")
                            .font(.pretendard(.regular, size: 14))
                            .foregroundStyle(Color.redText)
                        
                        Spacer()
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        showWithdrawalSheet = true
                    }
                    .padding(.top, 20)
                    
                }
                
            }
            .padding(.horizontal, 12)
            
        }
        .onAppear {
            Task {
                await viewModel.getUserInfo()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showWithdrawalSheet) {
            VStack(spacing: 20) {
                Text("회원을 탈퇴하시겠습니까?")
                    .font(.pretendard(.semibold, size: 20))
                    .foregroundStyle(Color.basicText)
                    .padding(.top, 20)
                
                Text("이메일을 입력해주세요.")
                    .font(.pretendard(.regular, size: 14))
                    .foregroundStyle(Color.placeholder)
                
                InputFieldView(text: $email, placeholder: "이메일", showCount: false, showAlert: false)
                
                SubmitButtonView(text: "확인", loading: viewModel.isLoading, disabled: email.isEmpty) {
                    Task {
                        showWithdrawalSheet = false
                        await viewModel.withdrawal(email: email)
                    }
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
            .background(Color.memoBackground)
        }
    }
}

