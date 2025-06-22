//
//  SplashView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/9/25.
//

import SwiftUI
import Factory

struct SplashView: View {
    @InjectedObservable(\.navigation) private var navigation: Navigation
    @InjectedObservable(\.appState) private var appState: AppState
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            ProgressView().progressViewStyle(CircularProgressViewStyle())
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            checkLogin()
        }
    }
    
    func checkLogin() {
        Task {
            guard let _ = KeyChainManager.shared.readAccessToken(),
                  let _ = KeyChainManager.shared.readRefreshToken() else {
                navigation.reset()
                navigation.push(to: .login)
                return
            }
            navigation.reset()
            navigation.push(to: .main)
        }
    }
}
