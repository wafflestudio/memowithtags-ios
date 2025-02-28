//
//  contextMenu.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/25/25.
//

import SwiftUI

struct CustomContextMenu: ViewModifier {
    @State var isPresented: Bool = false
    let actions: () -> AnyView
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture {
                isPresented.toggle()
            }
            .confirmationDialog("", isPresented: $isPresented) {
                actions()
            }
            
    }
}
extension View {
    func customContextMenu(actions: @escaping () -> AnyView) -> some View {
        self.modifier(CustomContextMenu(actions: actions))
    }
}
