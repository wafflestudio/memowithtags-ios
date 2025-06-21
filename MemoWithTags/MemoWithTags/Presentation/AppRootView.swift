//
//  SplashView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI
import Factory

struct AppRootView: View {
    @InjectedObservable(\.navigation) private var navigation: Navigation
    @InjectedObservable(\.alert) private var alert: Alert
    
    var body: some View {
        //MARK: - 네비게이션
        NavigationStack(path: $navigation.path) {
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
                        
                    //로그인
                    case .login:
                        LoginView()

                    //회원가입, 비밀번호 찾기
                    case .emailEnter, .resetPasswordEmailEnter:
                        EmailEnterView()
                    case .emailVerification(let email), .resetPasswordEmailVerification(let email):
                        EmailVerificationView(email: email)
                    case .signup(let email):
                        SignupView(email: email)
                    case .signupSuccess, .resetPasswordSuccess:
                        SignupSuccessView()
                    case .nicknameSetting:
                        NicknameSettingView()
                    case .resetPassword(let email):
                        ResetPasswordView(email: email)
                      
                    //세팅
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
        //MARK: - context menu
        .overlay {            
            if container.appState.system.showContextMenu {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        
                    BackdropBlurView(radius: 6)
                    
                    let anchorX = container.appState.system.previewAnchor!.x
                    let anchorY = container.appState.system.previewAnchor!.y
                    let isTopHalf = anchorY <= UIScreen.main.bounds.height / 2
        
                    GeometryReader { proxy in
                        VStack(spacing: 15) {
                            ContextMenu(menuItems: container.appState.system.menuItems) {
                                container.appState.system.showContextMenu = false
                            }
                            .opacity(isTopHalf ? 0 : 1)
                            
                            Preview(type: container.appState.system.previewType!)
                            
                            ContextMenu(menuItems: container.appState.system.menuItems) {
                                container.appState.system.showContextMenu = false
                            }
                            .opacity(isTopHalf ? 1 : 0)
                        }
                        .position(x: anchorX, y: anchorY)
                    }
                    
                }
                .onAppear {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .ignoresSafeArea()
                .onTapGesture {
                    container.appState.system.showContextMenu = false
                }
            }
        }
        //MARK: - 외부 링크에서 접근 (소셜 로그인)
        .onOpenURL { url in
            Task {
                await deepLinkHandler.handle(url: url)
            }
        }
        //MARK: - alert
        .alert(isPresented: $alert.showAlert) {
            let error = alert.error
            
            if let customError = error as? CustomError {
                switch customError.type {
                case .relogin:
                    return Alert(
                        title: Text("인증 오류"),
                        message: Text(customError.localizedDescription),
                        dismissButton: .default(Text("재로그인"), action: {
                            _ = KeyChainManager.shared.deleteAccessToken()
                            _ = KeyChainManager.shared.deleteRefreshToken()
                            
                            navigation.reset()
                            navigation.push(to: .root)
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


//extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        interactivePopGestureRecognizer?.delegate = self
//    }
//
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return viewControllers.count > 1
//    }
//}
