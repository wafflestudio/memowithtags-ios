import SwiftUI
import WebKit

class WebViewCoordinator: NSObject, WKScriptMessageHandler {
    @Binding var formatState: [String: Bool]
    @Binding var height: CGFloat
    @Binding var htmlContent: String
    @Binding var plainText: String

    init(formatState: Binding<[String: Bool]>, height: Binding<CGFloat>, htmlContent: Binding<String>, plainText: Binding<String>) {
        _formatState = formatState
        _height = height
        _htmlContent = htmlContent
        _plainText = plainText
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "formatUpdate":
            if let dict = message.body as? [String: Any] {
                var newState: [String: Bool] = [:]
                            
                // 기본 텍스트 스타일
                for key in ["bold", "italic", "underline", "strike"] {
                    newState[key] = (dict[key] as? Bool) ?? false
                }

                // 리스트 스타일
                if let list = dict["list"] as? String {
                    newState["listBullet"] = (list == "bullet")
                    newState["listOrdered"] = (list == "ordered")
                } else {
                    newState["listBullet"] = false
                    newState["listOrdered"] = false
                }

                // 정렬 스타일
                if let align = dict["align"] as? String {
                    newState["alignLeft"] = false
                    newState["alignCenter"] = (align == "center")
                    newState["alignRight"] = (align == "right")
                    newState["alignJustify"] = (align == "justify")
                } else {
                    // align 없으면 left로 간주
                    newState["alignLeft"] = true
                    newState["alignCenter"] = false
                    newState["alignRight"] = false
                    newState["alignJustify"] = false
                }

                DispatchQueue.main.async {
                    self.formatState = newState
                }
            }

        case "heightUpdate":
            if let h = message.body as? CGFloat {
                DispatchQueue.main.async {
                    self.height = h
                }
            }
            
        case "textUpdate":
            if let dict = message.body as? [String: Any] {
                let html = dict["html"] as? String ?? ""
                let text = dict["text"] as? String ?? ""
                DispatchQueue.main.async {
                    self.htmlContent = html
                    self.plainText = text
                }
            }

        default:
            break
        }
    }
}

class PlainWebView: WKWebView {
    var accessoryView: UIView?
    override var inputAccessoryView: UIView? {
        return accessoryView
    }
}

struct QuillWebView: UIViewRepresentable {
    @Binding var webView: WKWebView?
    @Binding var formatState: [String: Bool]
    @Binding var height: CGFloat
    @Binding var htmlContent: String
    @Binding var plainText: String


    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(formatState: $formatState, height: $height, htmlContent: $htmlContent, plainText: $plainText)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "formatUpdate")
        userContentController.add(context.coordinator, name: "heightUpdate")
        userContentController.add(context.coordinator, name: "textUpdate")
        config.userContentController = userContentController

        let view = PlainWebView(frame: .zero, configuration: config)

        if let url = Bundle.main.url(forResource: "quill", withExtension: "html") {
            view.loadFileURL(url, allowingReadAccessTo: url)
        } else {
            print("Quill HTML 파일을 찾을 수 없음")
            let htmlString = """
            <html><body style="background-color: lightgray; margin: 0; padding: 20px;">
            <h1>테스트 콘텐츠</h1>
            <p>HTML 파일이 로드되지 않았습니다.</p>
            </body></html>
            """
            view.loadHTMLString(htmlString, baseURL: nil)
        }

        DispatchQueue.main.async {
            self.webView = view
        }

        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

