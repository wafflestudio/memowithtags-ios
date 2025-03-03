//
//  SplashView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI

struct AppRootView: View {
    var container: DIContainer
    
    let deepLinkHandler: DeepLinkHandler
    
    // stateobject로 관리해야하는 viewmodel들 = 큼직큼직한 뷰들
    @StateObject private var mainViewModel: MainViewModel
    @StateObject private var loginViewModel: LoginViewModel
    @StateObject private var emailEnterViewModel: EmailEnterViewModel
    @StateObject private var emailVerificationViewModel: EmailVerificationViewModel
    @StateObject private var signupViewModel: SignupViewModel
    @StateObject private var resetPasswordViewModel: ResetPasswordViewModel
    
    
    init(container: DIContainer) {
        self.container = container
        self.deepLinkHandler = .init(appState: container.appState, socialLoginService: container.useCases.socialLoginService)
        
        _mainViewModel = StateObject(wrappedValue: MainViewModel(container: container))
        _loginViewModel = StateObject(wrappedValue: LoginViewModel(container: container))
        _emailEnterViewModel = StateObject(wrappedValue: EmailEnterViewModel(container: container))
        _emailVerificationViewModel = StateObject(wrappedValue: EmailVerificationViewModel(container: container))
        _signupViewModel = StateObject(wrappedValue: SignupViewModel(container: container))
        _resetPasswordViewModel = StateObject(wrappedValue: ResetPasswordViewModel(container: container))
    }
    
    var body: some View {
        NavigationStack(path: container.appState.$navigation.path) {
            SplashView(viewModel: .init(container: container))
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .root:
                        SplashView(viewModel: .init(container: container))
                    case .main:
                        MainView(viewModel: mainViewModel)
                    case .search:
                        SearchView(viewModel: mainViewModel)
                    case .memoEditor:
                        MemoEditorView(viewModel: mainViewModel)
                        
                    //MARK: - 로그인
                    case .login:
                        LoginView(viewModel: loginViewModel)

                    //MARK: - 회원가입, 비밀번호 찾기
                    case .emailEnter, .resetPasswordEmailEnter:
                        EmailEnterView(viewModel: emailEnterViewModel)
                    case .emailVerification(let email), .resetPasswordEmailVerification(let email):
                        EmailVerificationView(viewModel: emailVerificationViewModel, email: email)
                    case .signup(let email):
                        SignupView(viewModel: signupViewModel, email: email)
                    case .signupSuccess, .resetPasswordSuccess:
                        SignupSuccessView(viewModel: .init(container: container))
                    case .nicknameSetting:
                        NicknameSettingView(viewModel: .init(container: container))
                    case .resetPassword(let email):
                        ResetPasswordView(viewModel: resetPasswordViewModel, email: email)
                      
                    //MARK: - 세팅
                    case .settings:
                        SettingsView(viewModel: mainViewModel)
                    case .accountSetting:
                        AccountSettingView(viewModel: mainViewModel)
                    case .changePassword:
                        ChangePasswordView(viewModel: .init(container: container))
                    case .changeNickname:
                        ChangeNicknameView(viewModel: .init(container: container))
                    }
                }
        }
        .overlay {
            if container.appState.system.showContextMenu {
                ZStack {
                    BackdropBlurView(radius: 6)
                    
                    Circle()
                        .frame(width: 20, height: 20)
                        .position(container.appState.system.contextMenuAnchor!)

                }
                .ignoresSafeArea()
                .onTapGesture {
                    container.appState.system.showContextMenu = false
                }
            }
        }
        .onOpenURL { url in
            Task {
                await deepLinkHandler.handle(url: url)
            }
        }
        .alert(isPresented: container.appState.$system.showAlert) {
            let error = container.appState.system.error
            
            if let customError = error as? CustomError {
                switch customError.type {
                case .relogin:
                    return Alert(
                        title: Text("인증 오류"),
                        message: Text(customError.localizedDescription),
                        dismissButton: .default(Text("재로그인"), action: {
                            _ = KeyChainManager.shared.deleteAccessToken()
                            _ = KeyChainManager.shared.deleteRefreshToken()
                            
                            container.appState.navigation.reset()
                            container.appState.navigation.push(to: .root)
                        })
                    )
                    
                case .normal:
                    return Alert(
                        title: Text("오류"),
                        message: Text(customError.localizedDescription),
                        dismissButton: .default(Text("확인"))
                    )
                    
                case .fatal:
                    return Alert(
                        title: Text("치명적인 오류"),
                        message: Text(customError.localizedDescription),
                        dismissButton: .destructive(Text("앱 종료"), action: {
                            // 앱 종료 또는 강제 리셋 처리
                        })
                    )
                }
            } else {
                return Alert(
                    title: Text("알 수 없는 오류"),
                    message: Text(error?.localizedDescription ?? "정의되지 않은 오류입니다."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
}
