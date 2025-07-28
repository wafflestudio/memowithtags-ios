//
//  BackDropBlur.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/4/25.
//

import SwiftUI

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
