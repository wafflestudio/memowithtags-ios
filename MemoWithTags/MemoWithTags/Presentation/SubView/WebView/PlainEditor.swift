//
//  PlainEditor.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/27/25.
//

import SwiftUI
import Factory

struct PlainEditor: View {
    @Binding var text: String
    
    @InjectedObservable(\.appState) private var appState

    let placeholder: String = "새로운 메모"
    let maxHeight: CGFloat = 100
    
    private var fontSize: CGFloat {
        appState.fontSize == .small ? 14 : appState.fontSize == .medium ? 15 : 16
    }
    
    var body: some View {
        TextEditor(text: $text)
            .font(.pretendard(.regular, size: fontSize))
            .foregroundStyle(Color.basicText)
            .lineSpacing(3)
            .frame(minHeight: 33, maxHeight: maxHeight)
            .fixedSize(horizontal: false, vertical: true)
            .scrollContentBackground(.hidden)
            .background(Color.editorBackground)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .overlay (
                Text(placeholder)
                    .font(.pretendard(.regular, size: 14))
                    .foregroundColor(Color.placeholder)
                    .offset(x: 5)
                    .allowsHitTesting(false)
                    .opacity(text.isEmpty ? 1 : 0)
                , alignment: .leading
            )
    }
}
