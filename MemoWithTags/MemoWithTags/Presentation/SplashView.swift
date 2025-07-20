//
//  SplashView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/9/25.
//

import SwiftUI
import Factory

struct SplashView: View {
    @InjectedObservable(\.splashViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    @InjectedObservable(\.appState) private var appState
    
    @State private var isLoading: Bool = true
    @State private var isAnimating: Bool = true
    
    @State private var displayedText = ""
    @State private var displayTag = false
    private let loadingText = "Memo with"
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 18) {
                HStack(spacing: 4) {
                    Text(displayedText)
                        .font(.pretendard(.semibold, size: 22))
                        .foregroundStyle(Color.basicText)
                        .onAppear {
                            Task {
                                displayedText = ""
                                for char in loadingText {
                                    displayedText.append(char)
                                    try? await Task.sleep(for: .seconds(0.1))
                                }
                                withAnimation(.default.delay(0.5)) {
                                    displayTag = true
                                }
                                try? await Task.sleep(for: .seconds(1))
                                
                                isAnimating = false
                            }
                        }
                    
                    if displayTag {
                        DesignTagView(text: "Tags", fontSize: 19, backGroundColor: .titleTag) {}
                    }
                }
                
                ProgressView()
                    .opacity(!isAnimating && isLoading ? 1 : 0)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            isLoading = true
            isAnimating = true
            displayTag = false
            
            appState.initialize()
            if checkLogin() {
                await viewModel.initialize()
            }
            
            isLoading = false
        }
        .onChange(of: isLoading) {
            if !isAnimating && !isLoading {
                if checkLogin() {
                    navigation.push(to: .main)
                } else {
                    navigation.push(to: .login)
                }
            }
        }
        .onChange(of: isAnimating) {
            if !isAnimating && !isLoading {
                if checkLogin() {
                    navigation.push(to: .main)
                } else {
                    navigation.push(to: .login)
                }
            }
        }
    }
    
    private func checkLogin() -> Bool {
        if let _ = KeyChainManager.shared.readAccessToken(),
           let _ = KeyChainManager.shared.readRefreshToken() {
            return true
        }
        return false
    }
}

@MainActor
@Observable
final class SplashViewModel {
    @ObservationIgnored @Injected(\.memoService) private var memoService
    @ObservationIgnored @Injected(\.tagService) private var tagService
    @ObservationIgnored @Injected(\.userService) private var userService
    @ObservationIgnored @Injected(\.settingService) private var settingService
    
    
    @ObservationIgnored @Injected(\.appState) private var appState
    @ObservationIgnored @Injected(\.alertState) private var alert
    
    //MARK: - 유저 정보 가져오는 함수
    func getUser() async {
        let result = await userService.getUser()
        
        switch result {
        case .success(let user):
            appState.user = user
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
    //MARK: - 태그 전부 가져오기
    func fetchTags() async {
        let result = await tagService.fetchTag()
        
        switch result {
        case .success(let tags):
            appState.tags = tags
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
    func fetchSetting() async {
        do {
            if let user = appState.user {
                let tagOrdering = try settingService.getTagOrdering(userId: user.userNumber)
                let onMemoTagSorting = try settingService.getOnMemoTagSorting(userId: user.userNumber)
                let favoriteTags = try settingService.getFavoriteTags(userId: user.userNumber)
                
                appState.tagOrdering = tagOrdering
                appState.isOnMemoTagSorting = onMemoTagSorting
                appState.favoriteTags = favoriteTags
            }

        } catch {
            alert.alert(error: error)
        }
    }
    
    //MARK: - 초기화 함수
    func initialize() async {
        await getUser()
        await fetchTags()
        await fetchSetting()
    }
}

extension Container {
    @MainActor
    var splashViewModel: Factory<SplashViewModel> {
        self { @MainActor in SplashViewModel() }.cached
    }
}
