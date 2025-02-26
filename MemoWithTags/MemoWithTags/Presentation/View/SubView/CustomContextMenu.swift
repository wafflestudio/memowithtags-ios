//
//  contextMenu.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/25/25.
//

import SwiftUI

struct CustomContextMenu: ViewModifier {
    @Binding var isPresented: Bool
    
    @State private var frame: CGRect = .zero
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            self.frame = proxy.frame(in: .global)
                        }
                        .onChange(of: proxy.frame(in: .global)) {
                            self.frame = proxy.frame(in: .global)
                        }
                }
            )
            .onLongPressGesture {
                isPresented.toggle()
            }
    }
}

extension View {
    func customContextMenu(isPresented: Binding<Bool>) -> some View {
        self.modifier(CustomContextMenu(isPresented: isPresented))
    }
}
