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
    @StateObject private var signupViewModel: SignupViewModel
    @StateObject private var emailVerificationViewModel: EmailVerificationViewModel
    @StateObject private var resetPasswordViewModel: ResetPasswordViewModel
    
    
    init(container: DIContainer) {
        self.container = container
        self.deepLinkHandler = .init(appState: container.appState, kakaoLoginUseCase: container.useCases.kakaoLoginUseCase, naverLoginUseCase: container.useCases.naverLoginUseCase, googleLoginUseCase: container.useCases.googleLoginUseCase)
        
        _mainViewModel = StateObject(wrappedValue: MainViewModel(container: container))
        _loginViewModel = StateObject(wrappedValue: LoginViewModel(container: container))
        _signupViewModel = StateObject(wrappedValue: SignupViewModel(container: container))
        _emailVerificationViewModel = StateObject(wrappedValue: EmailVerificationViewModel(container: container))
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
                    case .login:
                        LoginView(viewModel: loginViewModel)
                    case .signup:
                        SignupView(viewModel: signupViewModel)
                    case .emailVerification(let email):
                        EmailVerificationView(viewModel: emailVerificationViewModel, email: email)
                    case .signupSuccess:
                        SignupSuccessView(viewModel: .init(container: container))
                    case .forgotPassword:
                        ForgotPasswordView(viewModel: .init(container: container))
                    case .forgotPasswordEmailVerification(let email):
                        ForgotPasswordEmailVerificationView(viewModel: .init(container: container), email: email)
                    case .resetPassword(let email, let code):
                        ResetPasswordView(viewModel: resetPasswordViewModel, email: email, code: code)
                    case .resetPasswordSuccess:
                        ResetPasswordSuccessView(viewModel: .init(container: container))
                    case .nicknameSetting:
                        NicknameSettingView(viewModel: .init(container: container))
                    case .settings:
                        SettingsView(viewModel: mainViewModel)
                    case .accountSetting:
                        AccountSettingView(viewModel: mainViewModel)
                    case .changePassword:
                        ChangePasswordView(viewModel: .init(container: container))
                    case .changeNickname:
                        ChangeNicknameView(viewModel: .init(container: container))
                    case .search:
                        SearchView(viewModel: mainViewModel)
                    case .memoEditor(let namespace, let id):
                        if #available(iOS 18.0, *) {
                            MemoEditorView(viewModel: mainViewModel)
                                .navigationTransition(.zoom(sourceID: id, in: namespace))
                        } else {
                            MemoEditorView(viewModel: mainViewModel)
                        }
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
                title: Text("Error"),
                message: Text(container.appState.system.errorMessage),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}
