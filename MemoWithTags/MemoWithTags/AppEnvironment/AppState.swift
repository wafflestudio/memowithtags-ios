//
//  AppState.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation
import Factory

@MainActor
@Observable
final class AppState {
    var user: User?
    var memos: [Memo] = []
    var tags: [Tag] = []
    
    var isBioAuthenticated: Bool = false
}

extension Container {
    @MainActor
    var appState: Factory<AppState> {
        self { @MainActor in AppState() }.singleton
    }
}
