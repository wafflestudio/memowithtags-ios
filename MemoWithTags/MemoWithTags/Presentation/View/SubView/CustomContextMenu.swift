//
//  contextMenu.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/25/25.
//

import SwiftUI

struct CustomContextMenu: ViewModifier {
    @Binding var isPresented: Bool
    let menuContent: () -> AnyView
    
    @State private var frame: CGRect = .zero
    
    func body(content: Content) -> some View {
    }
}

extension View {
    func customContextMenu(isPresented: Binding<Bool>, @ViewBuilder menuContent: @escaping () -> AnyView) -> some View {
        self.modifier(CustomContextMenu(isPresented: isPresented, menuContent: menuContent))
    }
}
