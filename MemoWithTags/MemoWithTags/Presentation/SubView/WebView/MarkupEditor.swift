//
//  Mark.swift
//  test
//
//  Created by 최진모 on 5/12/25.
//

import SwiftUI
import WebKit

struct MarkupEditor: View {
    @Binding var text: String
    @Binding var html: String
    @Binding var webView: WKWebView?
    @Binding var formatState: [String: Bool]
    let dynamicHeight: Bool
    
    @State private var contentHeight: CGFloat = 0
    private let maxHeight: CGFloat = 200

    var body: some View {
        QuillWebView(webView: $webView, formatState: $formatState, height: $contentHeight, htmlContent: $html, plainText: $text)
            .frame(maxHeight: !dynamicHeight ? .infinity : contentHeight < maxHeight ? contentHeight : maxHeight)
            .overlay(Group {
                if text.isEmpty && contentHeight != 0 {
                    Text("메모를 작성해보세요.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                        .allowsHitTesting(false)
                }
            }, alignment: .topLeading)
    }
}
