//
//  font.swift
//  MemoWithTags
//
//  Created by 최진모 on 3/1/25.
//

import SwiftUI

extension Font {
    static func pretendard(size: CGFloat,  _ weight: Font.Weight) -> Font {
        let weightString: String
        switch weight {
        case .ultraLight: weightString = "Pretendard-UltraLight"
        case .thin: weightString = "Pretendard-Thin"
        case .light: weightString = "Pretendard-Light"
        case .regular: weightString = "Pretendard-Regular"
        case .medium: weightString = "Pretendard-Medium"
        case .semibold: weightString = "Pretendard-SemiBold"
        case .bold: weightString = "Pretendard-Bold"
        case .heavy: weightString = "Pretendard-ExtraBold"
        default: weightString = "Pretendard-Regular"
        }
        
        return .custom(weightString, size: size)
    }
}
