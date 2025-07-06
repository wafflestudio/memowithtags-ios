//
//  ReadPosition.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/5/25.
//

import SwiftUI

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
