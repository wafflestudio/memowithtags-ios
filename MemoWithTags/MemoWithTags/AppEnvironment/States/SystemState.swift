//
//  SystemState.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/13/25.
//

import SwiftUI
import Foundation

@MainActor
final class SystemState: ObservableObject {
    //MARK: - alert 관련
    @Published var showAlert: Bool = false
    @Published var error: Error? = nil
    
    func alert(error: Error) {
        self.showAlert = true
        self.error = error
    }
    
    //MARK: - context menu 관련
    @Published var showContextMenu: Bool = false
    @Published var previewAnchor: CGPoint? = nil
    @Published var previewType: PreviewType? = nil
    @Published var menuItems: [MenuStruct] = []
    func presentContextMenu(at anchor: CGPoint, type: PreviewType, menuItmes: [MenuStruct]) {
        self.showContextMenu = true
        self.previewAnchor = anchor
        self.previewType = type
        self.menuItems = menuItmes
    }
}
