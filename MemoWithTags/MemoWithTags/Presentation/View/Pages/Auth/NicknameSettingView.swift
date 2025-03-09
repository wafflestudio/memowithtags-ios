//
//  NicknameSettingView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/26/25.
//

import SwiftUI

struct NicknameSettingView: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var nickname: String = ""
    
    var body: some View {
        ZStack {
            Color.W2_1.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("닉네임 설정")
                        .font(.pretendard(.semibold, size: 16))
                        .foregroundStyle(Color.B2)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //login panel
                VStack(spacing: 0) {
                    VStack(spacing: 4) {
                        //MARK: - 닉네임 설정 필드
                        TextField (
                            "",
                            text: $nickname,
                            prompt:
                                Text("닉네임")
                                .font(.pretendard(.regular, size: 16))
                                .foregroundStyle(Color(hex: "#94979F"))
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .font(.pretendard(.regular, size: 16))
                        .background(.white)
                        .overlay (
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
                    
                    //MARK: - 확인 버튼
                    Button {
                        //action
                        Task {
                            await viewModel.setNickname(nickname: nickname)
                        }

                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("다음")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .font(.pretendard(.semibold, size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                    }
                    .background(nickname.isEmpty || viewModel.isLoading ? Color(hex: "#E3E3E7") : Color.B2)
                    .cornerRadius(22)
                    .padding(.top, 16)
                    .disabled(nickname.isEmpty || viewModel.isLoading)
                }
                .padding(.top, 18)
                .padding(.bottom, 24)
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

extension NicknameSettingView {
    @MainActor
    final class ViewModel: BaseViewModel, ObservableObject {
        @Published var isLoading = false
        
        func setNickname(nickname: String) async {
            guard !isLoading else { return }
            
            isLoading = true
            
            let result = await useCases.userService.changeNickname(nickname: nickname)
            
            switch result {
            case .success:
                appState.navigation.push(to: .signupSuccess)
            case .failure(let error):
                appState.system.alert(error: error)
            }
            
            isLoading = false
        }
    }
}
