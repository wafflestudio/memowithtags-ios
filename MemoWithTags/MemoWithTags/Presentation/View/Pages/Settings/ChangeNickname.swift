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
            VStack(spacing: 4) {
                TextField (
                    "",
                    text: $nickname,
                    prompt: Text("닉네임 입력")
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
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.setNickname(nickname: nickname)
                }
            } label: {
                Text("완료")
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 12)
                
            }
            .background(nickname.isEmpty ? Color(hex: "#E3E3E7") : Color.titleTextBlack)
            .cornerRadius(22)
            .disabled(nickname.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .regular))
                    .onTapGesture {
                        viewModel.appState.navigation.pop()
                    }
            }
            
            ToolbarItem(placement: .navigation) {
                Text("닉네임 변경")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.titleTextBlack)
            }
        }
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
