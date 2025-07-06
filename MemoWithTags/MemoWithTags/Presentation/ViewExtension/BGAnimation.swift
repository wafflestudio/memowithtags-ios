//
//  BGAnimation.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/6/25.
//

import SwiftUI
import Factory

extension View {
    func bgAnimation() -> some View {
        self.modifier(
            BGAnimation()
        )
    }
}

struct BGAnimation: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
