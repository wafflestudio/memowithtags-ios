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
    @Published var contextMenuAnchor: CGPoint? = nil
    
    func presentContextMenu(at anchor: CGPoint) {
        self.showContextMenu = true
        self.contextMenuAnchor = anchor
    }
}
