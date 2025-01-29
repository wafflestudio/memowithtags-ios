//
//  ㅅ.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/26/25.
//

import Foundation

extension NSAttributedString {
    /// `NSAttributedString`을 `HTML` 문자열로 변환하는 함수
    func toHTML() -> String? {
        do {
            let range = NSRange(location: 0, length: self.length)
            let data = try self.data(
                from: range,
                documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
            )
            return String(data: data, encoding: .utf8)
        } catch {
            print("attr -> html 변환 실패")
            return nil
        }
    }
    
    /// `HTML` 문자열을 `NSAttributedString`으로 변환하는 초기화 함수
    convenience init?(html: String) {
        guard let data = html.data(using: .utf8) else { return nil }
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            try self.init(data: data, options: options, documentAttributes: nil)
        } catch {
            print("html -> attr 변환 실패")
            return nil
        }
    }
}
