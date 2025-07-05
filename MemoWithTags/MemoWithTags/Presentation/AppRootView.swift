//
//  SplashView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI
import Factory

struct AppRootView: View {
    @InjectedObservable(\.navigationState) private var navigation
    @InjectedObservable(\.alertState) private var alert
    
    @InjectedObservable(\.contextMenuAction) private var contextMenuAction
    
    @State private var showContextMenu: Bool = false
    
    @Namespace private var namespace
    
    var body: some View {
        //MARK: - 네비게이션
        NavigationStack(path: $navigation.path) {
            SplashView()
                .onAppear { navigation.namespace = namespace }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .root:
                        SplashView()
                    case .main:
                        MainView()
                    case .search:
                        SearchView()
                    case .fullEditor(let id):
                        FullEditorView()
                            .navigationTransition(.zoom(sourceID: id, in: namespace))
                    
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
                        SettingsView()
                    case .accountSetting:
                        AccountSettingView()
                    case .changePassword:
                        ChangePasswordView()
                    case .changeNickname:
                        ChangeNicknameView()
                    }
                }
        }
        //MARK: - Context Menu
        .onChange(of: contextMenuAction.signal) {
            showContextMenu = true
        }
        .overlay {
            if showContextMenu, let contextMenu = contextMenuAction.pop(){
                ZStack {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        
                    BackdropBlurView(radius: 10)
                    
                    let anchorX = contextMenu.position.midX
                    let anchorY = contextMenu.position.midY
                    let isTopHalf = anchorY <= UIScreen.main.bounds.height / 2
        
                    GeometryReader { proxy in
                        VStack(spacing: 15) {
                            ContextMenuView(menuItems: contextMenu.menu, isTopHalf: isTopHalf) {
                                showContextMenu = false
                            }
                            .opacity(isTopHalf ? 0 : 1)
                            
                            Preview(type: contextMenu.preview, position: contextMenu.position)
                            
                            ContextMenuView(menuItems: contextMenu.menu, isTopHalf: isTopHalf) {
                                showContextMenu = false
                            }
                            .opacity(isTopHalf ? 1 : 0)
                        }
                        .position(x: anchorX, y: anchorY)
                    }
                    
                }
                .ignoresSafeArea()
                .onAppear {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onTapGesture {
                    showContextMenu = false
                }
            }
        }
        //MARK: - 외부 링크에서 접근 (소셜 로그인)
//        .onOpenURL { url in
//            Task {
//                await deepLinkHandler.handle(url: url)
//            }
//        }
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
                            /* 앱 종료 또는 강제 리셋 처리 */
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
