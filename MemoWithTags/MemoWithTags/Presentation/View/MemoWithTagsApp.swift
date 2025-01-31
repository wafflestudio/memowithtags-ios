//
//  MemoWithTagsApp.swift
//  MemoWithTags
//
//  Created by 최진모 on 12/26/24.
//

import SwiftUI

@main
struct MemoWithTagsApp: App {
    
    @StateObject private var userState = UserState()
    @StateObject private var systemState = SystemState()
    @StateObject private var navigationState = NavigationState()
    
    var body: some Scene {
        WindowGroup {
            AppRootView(container: .init(
                appState: AppState(user: userState, system: systemState, navigation: navigationState)
            ))
        }
    }
}
