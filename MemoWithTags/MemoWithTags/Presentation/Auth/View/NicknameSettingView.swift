//
//  NicknameSettingView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/26/25.
//

import SwiftUI
import Factory

struct NicknameSettingView: View {
    @InjectedObservable(\.nicknameSettingViewModel) private var viewModel
    
    @State private var nickname: String = ""
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("닉네임 설정")
                        .font(.pretendard(.semibold, size: 16))
                        .foregroundStyle(Color.basicText)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //login panel
                VStack(spacing: 0) {
                    InputFieldView(text: $nickname, placeholder: "닉네임", showCount: true, showAlert: nickname.count > 16)
                    
                    //MARK: - 확인 버튼
                    SubmitButtonView(text: "다음", loading: viewModel.isLoading, disabled: !(1...16 ~= nickname.count)) {
                        Task {
                            await viewModel.setNickname(nickname: nickname)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.top, 18)
                .padding(.bottom, 24)
                .padding(.horizontal, 16)
                .background(Color.memoBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 12)
            .background(.clear)
            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)

        }
        .navigationBarBackButtonHidden()
    }
}
