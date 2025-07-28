//
//  MarkupToolbarButton.swift
//  test
//
//  Created by 최진모 on 5/12/25.
//

import SwiftUI
import WebKit

enum ToolbarButtonType {
    case bold
    case italic
    case underline
    case strike
    case listBullet
    case listOrdered
    case alignLeft
    case alignCenter
    case alignRight
    case alignJustify
    
    var icon: String {
        switch self {
        case .bold:
            return "bold"
        case .italic:
            return "italic"
        case .underline:
            return "underline"
        case .strike:
            return "strikethrough"
        case .listBullet:
            return "list.bullet"
        case .listOrdered:
            return "list.number"
        case .alignLeft:
            return "text.alignleft"
        case .alignCenter:
            return "text.aligncenter"
        case .alignRight:
            return "text.alignright"
        case .alignJustify:
            return "text.justify"
        }
    }
    
    var script: String {
        switch self {
        case .bold:
            return "togleStyle('bold')"
        case .italic:
            return "togleStyle('italic')"
        case .underline:
            return "togleStyle('underline')"
        case .strike:
            return "togleStyle('strike')"
        case .listBullet:
            return "togleStyle('list', 'bullet')"
        case .listOrdered:
            return "togleStyle('list', 'ordered')"
        case .alignLeft:
            return "togleStyle('align', false)"
        case .alignCenter:
            return "togleStyle('align', 'center')"
        case .alignRight:
            return "togleStyle('align', 'right')"
        case .alignJustify:
            return "togleStyle('align', 'justify')"
        }
    }
}

struct MarkupToolbarButton: View {
    @Binding var webView: WKWebView?
    let type: ToolbarButtonType
    let selected: Bool
    
    var body: some View {
        Button {
            executeScript(type.script)
        } label: {
            Image(systemName: type.icon)
                .font(.system(size: 18))
                .foregroundStyle(selected ? .black : .gray)
        }
    }
    
    private func executeScript(_ script: String) {
        webView?.evaluateJavaScript(script)
    }
}
