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
        .onOpenURL { url in
            Task {
                await deepLinkHandler.handle(url: url)
            }
        }
        .alert(isPresented: container.appState.$system.showAlert) {
            return Alert(
                title: Text("에러"),
                message: Text(container.appState.system.error?.localizedDescription ?? "Unable to define error"),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}
