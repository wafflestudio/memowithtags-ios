//
//  contextMenu.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/25/25.
//

import SwiftUI
import Factory

//MARK: - view modifier 설정
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
    
    @State private var position: CGRect?
    @State private var pressLocation: CGPoint?
    
    @State private var isPressed = false
    
    let preview: PreviewType
    let menu: [MenuElement]
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1)
            .onLongPressGesture {
                if let position = position, let pressLocation = pressLocation {
                    if position.minY < 50 || position.maxY > UIScreen.main.bounds.height - 50 {
                        let newPosition = CGRect(
                            x: position.minX,
                            y: position.minY + pressLocation.y - position.height/2,
                            width: position.width,
                            height: position.height
                        )
                        action.push(.init(position: newPosition, preview: preview, menu: menu))
                    } else {
                        action.push(.init(position: position, preview: preview, menu: menu))
                    }
                }
            } onPressingChanged: { isPressing in
                self.isPressed = isPressing
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        pressLocation = value.location
                    }
            )
            .readPosition { newPosition in
                position = newPosition
            }
    }
}

//MARK: - 위치 추적
extension View {
    func readPosition(onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: PositionPreferenceKey.self,
                        value: proxy.frame(in: .global)
                    )
            }
        )
        .onPreferenceChange(PositionPreferenceKey.self, perform: onChange)
    }
}

struct PositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}
