//
//  MarkupToolbar.swift
//  test
//
//  Created by 최진모 on 5/12/25.
//
import SwiftUI
import WebKit

struct MarkupToolbar: View {
    @Binding var webView: WKWebView?
    @Binding var formatState: [String: Bool]
    
    var body: some View {
        HStack {
            MarkupToolbarButton(webView: $webView, type: .bold, selected: formatState["bold"] ?? false)
            MarkupToolbarButton(webView: $webView, type: .italic, selected: formatState["italic"] ?? false)
            MarkupToolbarButton(webView: $webView, type: .underline, selected: formatState["underline"] ?? false)
            MarkupToolbarButton(webView: $webView, type: .strike, selected: formatState["strike"] ?? false)
            MarkupToolbarButton(webView: $webView, type: .listOrdered, selected: formatState["listOrdered"] ?? false)
            MarkupToolbarButton(webView: $webView, type: .listBullet, selected: formatState["listBullet"] ?? false)
            MarkupToolbarButton(webView: $webView, type: .alignLeft, selected: formatState["alignLeft"] ?? false)
            MarkupToolbarButton(webView: $webView, type: .alignCenter, selected: formatState["alignCenter"] ?? false)
            MarkupToolbarButton(webView: $webView, type: .alignRight, selected: formatState["alignRight"] ?? false)
            MarkupToolbarButton(webView: $webView, type: .alignJustify, selected: formatState["alignJustify"] ?? false)
        }
    }
}
