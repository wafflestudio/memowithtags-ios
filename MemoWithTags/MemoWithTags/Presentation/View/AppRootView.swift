//
//  SplashView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI

struct AppRootView: View {
    var container: DIContainer
    
    /// DeepLink 전용 핸들러
    let deepLinkHandler: DeepLinkHandler
    
    // stateobject로 관리해야 하는 ViewModel들
    @StateObject private var mainViewModel: MainViewModel
    @StateObject private var loginViewModel: LoginViewModel
    @StateObject private var emailEnterViewModel: EmailEnterViewModel
    @StateObject private var emailVerificationViewModel: EmailVerificationViewModel
    @StateObject private var signupViewModel: SignupViewModel
    @StateObject private var resetPasswordViewModel: ResetPasswordViewModel
    
    init(container: DIContainer) {
        self.container = container
        
        // DeepLinkHandler를 socialLoginService만 주입받도록 변경
        self.deepLinkHandler = DeepLinkHandler(
            appState: container.appState,
            socialLoginService: container.useCases.socialLoginService
        )
        
        // 각 화면(View)에 연결될 ViewModel들 초기화
        _mainViewModel = StateObject(wrappedValue: MainViewModel(container: container))
        _loginViewModel = StateObject(wrappedValue: LoginViewModel(container: container))
        _emailEnterViewModel = StateObject(wrappedValue: EmailEnterViewModel(container: container))
        _emailVerificationViewModel = StateObject(wrappedValue: EmailVerificationViewModel(container: container))
        _signupViewModel = StateObject(wrappedValue: SignupViewModel(container: container))
        _resetPasswordViewModel = StateObject(wrappedValue: ResetPasswordViewModel(container: container))
    }
    
    var body: some View {
        NavigationStack(path: container.appState.$navigation.path) {
            // 가장 먼저 띄워지는 화면 (Splash)
            SplashView(viewModel: .init(container: container))
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .root:
                        SplashView(viewModel: .init(container: container))
                        
                    // 메인/검색 화면
                    case .main:
                        MainView(viewModel: mainViewModel)
                    case .search:
                        SearchView(viewModel: mainViewModel)
                        
                    // 로그인
                    case .login:
                        LoginView(viewModel: loginViewModel)
                        
                    // 회원가입 & 비밀번호 찾기 관련
                    case .emailEnter, .resetPasswordEmailEnter:
                        EmailEnterView(viewModel: emailEnterViewModel)
                    case .emailVerification(let email), .resetPasswordEmailVerification(let email):
                        EmailVerificationView(viewModel: emailVerificationViewModel, email: email)
                    case .signup:
                        SignupView(viewModel: signupViewModel)
                    case .signupSuccess, .resetPasswordSuccess:
                        SignupSuccessView(viewModel: .init(container: container))
                    case .nicknameSetting:
                        NicknameSettingView(viewModel: .init(container: container))
                    case .resetPassword(let email, let code):
                        ResetPasswordView(viewModel: resetPasswordViewModel, email: email, code: code)
                      
                    // 설정/계정 관련
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
        // URL 스킴으로 들어온 경우(소셜 로그인 등) 이 부분 필요한지 다시 확인해야 함
        .onOpenURL { url in
            Task {
                await deepLinkHandler.handle(url: url)
            }
        }
        // Alert 공통 처리
        .alert(isPresented: container.appState.$system.showAlert) {
            Alert(
                title: Text("에러"),
                message: Text(container.appState.system.errorMessage),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}

