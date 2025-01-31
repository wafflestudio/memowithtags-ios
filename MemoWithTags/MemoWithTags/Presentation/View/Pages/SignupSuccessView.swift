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
            Color.backgroundGray.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //title
                HStack(spacing: 4) {
                    Text("회원가입이 완료되었습니다!")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(Color.titleTextBlack)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //auth panel
                VStack(spacing: 0) {
                    //환영글
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            HStack(spacing: 3) {
                                Text("Memo with")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color.titleTextBlack)
                                
                                DesignTagView(text: "Tags", fontSize: 14, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#E3E3E7", cornerRadius: 4) {}
                            }
                            Text("를 통해")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.titleTextBlack)
                        }
                        Text("복잡한 메모들을 간단하고 효율적으로 정리해보세요!")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.titleTextBlack)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    
                    //시작버튼
                    Button {
                        //action
                        viewModel.start()
                    } label: {
                        Text("시작하기")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 16, weight: .semibold))
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
