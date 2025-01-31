//
//  AccountSettingView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/26/25.
//

import SwiftUI

struct AccountSettingView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.backgroundGray
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                VStack(alignment: .leading) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.leading, 40)
                    } else {
                        Text("\(viewModel.appState.user.userName ?? "") 님")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.titleTextBlack)
                        
                        HStack {
                            Text("#\(viewModel.appState.user.userNumber ?? 0)")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.dateGray)
                            
                            Spacer()
                            
                            Text("닉네임 변경")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.titleTextBlack)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 6)
                                .background(Color.backgroundGray)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .onTapGesture {
                                    viewModel.appState.navigation.push(to: .changeNickname)
                                }
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
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .regular))
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
    }
}

