//
//  ㅅ.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/26/25.
//

import Foundation

final class TextFormatManager {
    static let shared = TextFormatManager()
    private init() {}
    
    func attributedStringToHTML(attributedString: NSAttributedString) -> String? {
        do {
            let data = try attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
            )
            return String(data: data, encoding: .utf8)
        } catch {
            print("NSAttributedString -> HTML 변환 실패: \(error)")
            return nil
        }
    }
    
    func htmlToAttributedString(html: String) -> NSAttributedString? {
        guard let data = html.data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            print("HTML -> NSAttributedString 변환 실패: \(error)")
            return nil
        }
    }
}
