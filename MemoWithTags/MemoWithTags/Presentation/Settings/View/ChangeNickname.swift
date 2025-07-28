//
//  ChangePasswordView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/27/25.
//

import SwiftUI
import Factory

struct ChangeNicknameView: View {
    @InjectedObservable(\.settingViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    @InjectedObservable(\.appState) private var appState

    @State private var nickname: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            //MARK: - navigation bar
            HStack(spacing: 0) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19))
                    .foregroundStyle(Color.soft)
                    .padding(12) // 터치 영역을 확장하기 위해 패딩 추가
                    .contentShape(Rectangle()) // 전체 영역을 터치 가능 영역으로 지정
                    .onTapGesture {
                        navigation.pop()
                    }
                
                Text("닉네임 변경")
                    .font(.pretendard(.semibold, size: 18))
                    .foregroundStyle(Color.basicText)
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            //MARK: -
            
            InputFieldView(text: $nickname, placeholder: "닉네임", showCount: true, showAlert: nickname.count > 16)
            
            Spacer()
            
            SubmitButtonView(text: "완료", loading: viewModel.isLoading, disabled: !(1...16 ~= nickname.count)) {
                Task {
                    await viewModel.setNickname(nickname: nickname)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
        .background(Color.memoBackground)
        .navigationBarBackButtonHidden()
        .onAppear {
            nickname = appState.user?.nickname ?? ""
        }
    }
}
