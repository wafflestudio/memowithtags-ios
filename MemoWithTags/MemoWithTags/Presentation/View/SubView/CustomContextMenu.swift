//
//  contextMenu.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/25/25.
//

import SwiftUI

extension View {
    func customContextMenu<MenuView: View>(
        appState: AppState,
        menu: @escaping () -> MenuView
        
    ) -> some View {
        self.modifier(
            CustomContextMenu(
                appState: appState,
                Menu: menu
            )
        )
    }
}

struct CustomContextMenu<MenuView: View>: ViewModifier {
    @State private var position: CGPoint?
    
    let appState: AppState
    let Menu: () -> MenuView
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture {
                appState.system.presentContextMenu(at: position!)
            }
            .readPosition { newPosition in
                position = newPosition
            }
    }
}

//MARK: - 위치 추적
extension View {
    func readPosition(onChange: @escaping (CGPoint) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: PositionPreferenceKey.self,
                        value: CGPoint(
                            x: proxy.frame(in: .global).midX,
                            y: proxy.frame(in: .global).midY
                        )
                    )
            }
        )
        .onPreferenceChange(PositionPreferenceKey.self, perform: onChange)
    }
}

struct PositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

//MARK: - 배경 블러
struct BackdropView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect()
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = blur }
        animator.fractionComplete = 0
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}

struct BackdropBlurView: View {
    let radius: CGFloat

    @ViewBuilder
    var body: some View {
        BackdropView().blur(radius: radius)
    }
}

//MARK: - 프리뷰
typealias Preview = View

struct MemoPreview: Preview {
    var body: some View {
        Text("hi")
    }
}

struct TagPreview: Preview {
    var body: some View {
        Text("hi")
    }
}
