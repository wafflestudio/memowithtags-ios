//
//  ChangePasswordView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/27/25.
//

import SwiftUI
import Factory

struct ChangePasswordView: View {
    @InjectedObservable(\.settingViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var newPasswordRepeat: String = ""
    
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
                
                Text("비밀번호 변경")
                    .font(.pretendard(.semibold, size: 18))
                    .foregroundStyle(Color.basicText)
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            //MARK: -
            
            VStack(spacing: 10) {
                SecureInputFieldView(password: $currentPassword, placeholder: "기존 비밀번호", showCondition: false)
                SecureInputFieldView(password: $newPassword, placeholder: "새 비밀번호", showCondition: true)
                SecureInputFieldView(password: $newPasswordRepeat, placeholder: "비밀번호 확인", showCondition: false)
            }
            
            Spacer()
            
            SubmitButtonView(
                text: "완료", loading: viewModel.isLoading, disabled: currentPassword.isEmpty || newPassword.isEmpty || newPasswordRepeat.isEmpty
            ) {
                Task {
                    await viewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword, newPasswordRepeat: newPasswordRepeat)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
        .background(Color.memoBackground)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.checkPasswordValidity(password: newPassword)
        }
    }
}
