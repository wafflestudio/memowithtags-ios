//
//  SplashView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/9/25.
//

import SwiftUI

struct SplashView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Color.backgroundGray.edgesIgnoringSafeArea(.all)
            ProgressView().progressViewStyle(CircularProgressViewStyle())
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.checkLogin()
        }
    }
}

extension SplashView {
    @MainActor
    final class ViewModel: BaseViewModel, ObservableObject {
        func checkLogin() {
            Task {
                // AIModel warm-up: dummy 텍스트를 인코딩하여 초기화를 강제합니다.
                do {
                    _ = try AIModel.shared.encode(texts: ["dummy"])
                } catch {
                    print("AIModel warm-up 실패: \(error)")
                }
                
                guard let _ = KeyChainManager.shared.readAccessToken(),
                      let _ = KeyChainManager.shared.readRefreshToken() else {
                    appState.user.isLoggedIn = false
                    appState.navigation.reset()
                    appState.navigation.push(to: .login)
                    return
                }
                appState.user.isLoggedIn = true
                appState.navigation.reset()
                appState.navigation.push(to: .main)
            }
        }
    }
}
