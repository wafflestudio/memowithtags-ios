//
//  ChangePasswordView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/27/25.
//

import SwiftUI

struct ChangeNicknameView: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var nickname: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.soft)
                    .onTapGesture {
                        viewModel.appState.navigation.pop()
                    }
            }
            
            ToolbarItem(placement: .navigation) {
                Text("닉네임 변경")
                    .font(.pretendard(.semibold, size: 18))
                    .foregroundStyle(Color.basicText)
            }
        }
        .background(Color.memoBackground)
        .navigationBarBackButtonHidden()
    }
}

extension ChangeNicknameView {
    @MainActor
    final class ViewModel: BaseViewModel, ObservableObject {
        @Published var isLoading = false
        
        func setNickname(nickname: String) async {
            guard !isLoading else { return }
            
            isLoading = true
            
            let result = await useCases.userService.changeNickname(nickname: nickname)
            
            switch result {
            case .success:
                appState.navigation.pop()
            case .failure(let error):
                appState.system.alert(error: error)
            }
            
            isLoading = false
        }
    }
}
