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
                
                //조건 표시
                HStack {
                    Spacer()
                    Text("\(nickname.count)/8")
                        .font(.pretendard(.regular, size: 12))
                        .foregroundStyle(nickname.count > 8 ? Color.red : Color.W4)
                        .padding(.horizontal, 6)
                }
            }
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.setNickname(nickname: nickname)
                }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("완료")
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.pretendard(.semibold, size: 16))
                .foregroundStyle(.white)
                .padding(.vertical, 12)
            }
            .background(nickname.isEmpty || viewModel.isLoading ? Color(hex: "#E3E3E7") : Color.B2)
            .cornerRadius(22)
            .disabled(nickname.isEmpty || viewModel.isLoading)
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
                    .font(.pretendard(.semibold, size: 18))
                    .foregroundStyle(Color.B2)
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
