//
//  contextMenu.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/25/25.
//

import SwiftUI
import Factory

extension View {
    func customContextMenu(preview: PreviewType, _ menuItems: [MenuElement]) -> some View {
        self.modifier(
            CustomContextMenu(
                preview: preview,
                menu: menuItems
            )
        )
    }
}

struct CustomContextMenu: ViewModifier {
    @InjectedObservable(\.contextMenuAction) private var action
    
    let preview: PreviewType
    let menu: [MenuElement]
    
    @State private var position: CGRect = .zero
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture {
                action.push(.init(position: position, preview: preview, menu: menu))
            }
            .readPosition { pos in
                position = pos
            }
    }
}
