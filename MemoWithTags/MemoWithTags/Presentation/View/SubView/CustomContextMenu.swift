//
//  contextMenu.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/25/25.
//

import SwiftUI

struct CustomContextMenu: ViewModifier {
    @Binding var isPresented: Bool
    let Preview: () -> AnyView
    let Contextmenu: () -> AnyView
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture {
                isPresented.toggle()
            }
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    BackdropBlurView(radius: 10)
                        .onTapGesture {
                            isPresented.toggle()
                        }
                    
                    VStack(spacing: 15) {
                        Preview()
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                        Contextmenu()
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
                    }
                }
                .presentationBackground(.black.opacity(0.1))
                .transaction { transaction in
                    transaction.disablesAnimations = false
                }
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }
}
extension View {
    func customContextMenu(isPresented: Binding<Bool>, @ViewBuilder preview: @escaping () -> AnyView, @ViewBuilder contextmenu: @escaping () -> AnyView) -> some View {
        self.modifier(CustomContextMenu(isPresented: isPresented, Preview: preview, Contextmenu: contextmenu))
    }
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
