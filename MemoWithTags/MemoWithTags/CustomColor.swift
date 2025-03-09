//
//  CustomColor.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/28/24.
//

import SwiftUI

// MARK: - UIColor extension: 6자리 HEX 문자열을 UIColor로 변환
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let red   = CGFloat((int >> 16) & 0xFF) / 255.0
        let green = CGFloat((int >> 8) & 0xFF) / 255.0
        let blue  = CGFloat(int & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - SwiftUI Color extension: 실제 UIColor를 받아 동적 색상 생성
extension Color {
    /// 라이트 모드와 다크 모드에서 실제 UIColor 값을 받아 동적 색상을 생성합니다.
    static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }
    
    // 기본 색상 정의
    static let backgroundColor: Color = .dynamicColor(
        light: UIColor(hex: "#F1F1F3"), // W2_1
        dark: UIColor(hex: "#000000")   // B1
    )
    
    static let memoBackgroundColor: Color = .dynamicColor(
        light: UIColor(hex: "#FFFFFF"), // W1
        dark: UIColor(hex: "#1A1A1B")   //
    )
    
    static let editorBackgroundColor: Color = .dynamicColor(
        light: UIColor(hex: "#FFFFFF"), // W1
        dark: UIColor(hex: "#2F2F33")   //
    )
    
    static let editorPlaceholder: Color = .dynamicColor(
        light: UIColor(hex: "#A0A0A1"),
        dark: UIColor(hex: "#A0A0A1")
    )
    
    static let searchBarBackgroundColor: Color = .dynamicColor(
        light: UIColor(hex: "#E3E3E7"), // W3
        dark: UIColor(hex: "#2F2F33")   //
    )
    
    static let basicTextColor: Color = .dynamicColor(
        light: UIColor(hex: "#202021"), // B2
        dark: UIColor(hex: "#F5F5F5")   // W2
    )
    
    // 태그 텍스트 색상에 70% opacity 적용
    static let tagTextColor: Color = .dynamicColor(
        light: UIColor(hex: "#202021").withAlphaComponent(0.7), // B2_70
        dark: UIColor(hex: "#F5F5F5")                           // W2
    )
    
    static let basicGray: Color = .dynamicColor(
        light: UIColor(hex: "#A0A0A1"), // W4
        dark: UIColor(hex: "#1C1C1E")   //
    )
    
    static let textRed: Color = .dynamicColor(
        light: UIColor(hex: "#FF5151"), // textRed
        dark: UIColor(hex: "#FF5151")   // textRed
    )
    
    static let buttonRed: Color = .dynamicColor(
        light: UIColor(hex: "#FF9C9C"), // buttonRed
        dark: UIColor(hex: "#FF9C9C")   //
    )
    
    static let placeholderGrayInWhiteBackground: Color = .dynamicColor(
        light: UIColor(hex: "#94979F"), //
        dark: UIColor(hex: "#94979F")   //
    )
    
    static let strokeGrayInWhiteBackground: Color = .dynamicColor(
        light: UIColor(hex: "#DCDDDE"), //
        dark: UIColor(hex: "#DCDDDE")   //
    )
    
}

// MARK: - TagColor 열거형
extension Color {
    enum TagColor: String, CaseIterable, Encodable, Decodable {
        case Red = "#FF9C9C"
        case Red2 = "#FFBDBD"
        case Red3 = "#FFE3DA"
        case Yellow = "#FFF0B8"
        case Yellow2 = "#FFF56F"
        case Green = "#D4FDCB"
        case Green2 = "#DCF794"
        case Green3 = "#92EDA1"
        case Mint = "#CCFFF7"
        case Mint2 = "#A6F7EA"
        case Blue = "#D2E8FE"
        case Blue2 = "#B3D9FF"
        case Purple = "#EEDEFE"
        case Purple2 = "#DEBDFF"
        case Pink = "#FFBDDE"
        case Pink2 = "#FFD9EC"
        
        var color: Color {
            let base = UIColor(hex: self.rawValue)
            return Color.dynamicColor(light: base, dark: base.withAlphaComponent(0.3))
        }
    }
}
