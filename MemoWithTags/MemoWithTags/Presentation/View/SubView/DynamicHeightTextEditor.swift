//
//  DynamicHeightTextEditor.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/9/25.
//

import SwiftUI

struct DynamicHeightTextEditor: View {
    @Binding var text: String
    let placeholder: String = "새로운 메모"
    
    @State var dynamicHeight: CGFloat = 20
    let minHeight: CGFloat = 20
    let maxHeight: CGFloat
    let singleLineHeight: CGFloat = 20 // font size 16이 line height 20을 차지할 것이라 가정.

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .background(GeometryReader { geometry in
                    Color.editorBackgroundColor
                        .onAppear {
                            updateHeight(from: geometry.size)
                        }
                        .onChange(of: text) { _, _ in
                            // Calculate new height based on content
                            let newHeight = text.heightWithConstrainedWidth(
                                width: geometry.size.width,
                                font: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
                            )
                            DispatchQueue.main.async {
                                dynamicHeight = min(max(newHeight + singleLineHeight, minHeight), maxHeight)
                            }
                        }
                })
                .font(.pretendard(.regular, size: 14))
                .disableAutocorrection(true)
            
            if text.isEmpty {
                Text(placeholder)
                    .font(.pretendard(.regular, size: 14))
                    .foregroundColor(Color.editorPlaceholder)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 10)
                    .allowsHitTesting(false) // 플레이스홀더가 터치 이벤트를 차단하지 않도록 설정
            }
        }
        .frame(height: dynamicHeight)
    }

    private func updateHeight(from size: CGSize) {
        let calculatedHeight = text.heightWithConstrainedWidth(
            width: size.width,
            font: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        )
        dynamicHeight = min(max(calculatedHeight + singleLineHeight, minHeight), maxHeight)
    }
}

extension String {
    // Calculates the height required for the given string with constrained width and font.
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let adjustedWidth = max(width - 16, 1) // Ensure width is at least 1 to prevent invalid constraints
        let constraintRect = CGSize(width: adjustedWidth, height: .greatestFiniteMagnitude) // Adjust for padding
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
}
