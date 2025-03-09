//
//  SignupSuccessView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/6/25.
//

import SwiftUI

struct SignupSuccessView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Color.W2_1.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("회원가입이 완료되었습니다!")
                        .font(.pretendard(.semibold, size: 21))
                        .foregroundStyle(Color.B2)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //auth panel
                VStack(spacing: 0) {
                    //MARK: - 환영글
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            HStack(spacing: 3) {
                                Text("Memo with")
                                    .font(.pretendard(.semibold, size: 17))
                                    .foregroundStyle(Color.B2)
                                
                                DesignTagView(text: "Tags", fontSize: 14, fontWeight: .regular, horizontalPadding: 5, verticalPadding: 1, backGroundColor: "#E3E3E7", cornerRadius: 4) {}
                            }
                            Text("를 통해")
                                .font(.pretendard(.regular, size: 15))
                                .foregroundStyle(Color.B2)
                        }
                        Text("복잡한 메모들을 간단하고 효율적으로 정리해보세요!")
                            .font(.pretendard(.regular, size: 15))
                            .foregroundStyle(Color.B2)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    
                    //MARK: - 시작버튼
                    Button {
                        //action
                        viewModel.start()
                    } label: {
                        Text("시작하기")
                            .frame(maxWidth: .infinity)
                            .font(.pretendard(.semibold, size: 16))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                    }
                    .background(Color(hex: "#FF9C9C"))
                    .cornerRadius(22)
                    .padding(.top, 16)
                }
                .padding(.top, 18)
                .padding(.bottom, 16)
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

extension SignupSuccessView {
    @MainActor
    final class ViewModel: BaseViewModel, ObservableObject {
        func start() {
            
            if let _ = KeyChainManager.shared.readAccessToken(),
               let _ = KeyChainManager.shared.readRefreshToken() {
                appState.navigation.reset()
                appState.navigation.push(to: .main)
            } else {
                appState.navigation.reset()
                appState.navigation.push(to: .login)
            }
            
        }
    }
}
