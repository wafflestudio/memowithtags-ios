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
    @InjectedObservable(\.expandAction) private var expandAction
    @InjectedObservable(\.tagUpdateAction) private var tagUpdateAction
    
    @State private var showContextMenu: Bool = false
    
    @Namespace private var namespace
    
    var body: some View {
        //MARK: - 네비게이션
        ZStack {
            //MARK: - 네비게이션 컨텍스트 전환
            switch navigation.activeContext {
            case .splash:
                SplashView()

            case .auth:
                NavigationStack(path: $navigation.authPath) {
                    LoginView()
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .login:
                                LoginView()
                            case .emailEnter, .resetPasswordEmailEnter:
                                EmailEnterView()
                            case .emailVerification(let email), .resetPasswordEmailVerification(let email):
                                EmailVerificationView(email: email)
                            case .signup(let email):
                                SignupView(email: email)
                            case .signupSuccess:
                                SignupSuccessView()
                            case .resetPassword(let email):
                                ResetPasswordView(email: email)
                            case .resetPasswordSuccess:
                                ResetPasswordSuccessView()
                            case .nicknameSetting:
                                NicknameSettingView()
                            default:
                                Text("Invalid route for auth flow: \(String(describing: route))")
                            }
                        }
                }
                .transition(.opacity)
                
            case .main:
                NavigationStack(path: $navigation.mainPath) {
                    MainView()
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                             case .main:
                                 MainView()
                             case .search:
                                 SearchView()
                             case .settings:
                                 SettingsView()
                             case .accountSetting:
                                 AccountSettingView()
                             case .tagSetting:
                                 TagSettingView()
                             case .tagDetailedSetting(let tag):
                                 TagDetailedSettingView(tag: tag)
                             case .changePassword:
                                 ChangePasswordView()
                             case .changeNickname:
                                 ChangeNicknameView()
                             default:
                                 Text("Invalid route for main flow: \(String(describing: route))")
                             }
                        }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: navigation.activeContext)
        .onAppear {
            contextMenuAction.namespace = namespace
            expandAction.namespace = namespace
            tagUpdateAction.namespace = namespace
        }
        //MARK: - Context Menu
        .onChange(of: contextMenuAction.signal) {
            showContextMenu = true
        }
        .overlay {
            if showContextMenu, let contextMenu = contextMenuAction.pop() {
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
        .fullScreenCover(isPresented: $expandAction.signal) {
            if let target = expandAction.pop() {
                switch target.editState {
                case .create:
                    FullEditorView(initContent: target.content, initTags: target.tags, editState: target.editState)
                        .navigationTransition(.zoom(sourceID: "editor", in: expandAction.namespace))
                        .interactiveDismissDisabled()
                case .update(let memo):
                    FullEditorView(initContent: target.content, initTags: target.tags, editState: target.editState)
                        .navigationTransition(.zoom(sourceID: memo.id, in: expandAction.namespace))
                        .interactiveDismissDisabled()
                }
            }
        }
        .sheet(isPresented: $tagUpdateAction.signal) {
            if let target = tagUpdateAction.pop() {
                TagUpdaterView(tag: target.tag)
                    .presentationDetents([.fraction(0.7)])
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
                            
                            navigation.switchTo(.splash)
                        })
                    )
                    
                case .normal, .ignore:
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
                            _ = KeyChainManager.shared.deleteAccessToken()
                            _ = KeyChainManager.shared.deleteRefreshToken()
                            
                            navigation.switchTo(.splash)
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
        //MARK: - 외부 링크에서 접근 (소셜 로그인)
//        .onOpenURL { url in
//            Task {
//                await deepLinkHandler.handle(url: url)
//            }
//        }
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

