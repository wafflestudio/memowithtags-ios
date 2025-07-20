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

extension UIColor {
    struct Palette {
        static let B1 = UIColor(hex: "#000000")
        static let B2 = UIColor(hex: "#202021")
        static let B2_70 = UIColor(hex: "#202021").withAlphaComponent(0.7)
        static let B2_15 = UIColor(hex: "#202021").withAlphaComponent(0.15)
        static let B3 = UIColor(hex: "#2F2F33")
        
        static let W1 = UIColor(hex: "#FFFFFF")
        static let W2 = UIColor(hex: "#F5F5F5")
        static let W2_1 = UIColor(hex: "#F1F1F1")
        static let W3 = UIColor(hex: "#E3E3E7")
        static let W4 = UIColor(hex: "#A0A0A1")
        static let W4_60 = UIColor(hex: "#A0A0A1").withAlphaComponent(0.6)
        static let W4_30 = UIColor(hex: "#A0A0A1").withAlphaComponent(0.3)
        
        static let TextRed = UIColor(hex: "#FF5151")
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
    
    //MARK: - 배경색
    static let background: Color = .dynamicColor(
        light: .Palette.W2_1,
        dark: .Palette.B1
    )
    
    static let memoBackground: Color = .dynamicColor(
        light: .Palette.W1,
        dark: .Palette.B2
    )
    
    static let editorBackground: Color = .dynamicColor(
        light: .Palette.W1,
        dark: .Palette.B3
    )
    
    static let searchBarBackground: Color = .dynamicColor(
        light: .Palette.W3,
        dark: .Palette.B3
    )
    
    static let buttonBackground: Color = .dynamicColor(
        light: .Palette.B2,
        dark: .Palette.W4_60
    )
    
    static let disabledButtonBackground: Color = .dynamicColor(
        light: .Palette.W3,
        dark: .Palette.B3
    )
    
    //MARK: - 텍스트 및 아이콘
    static let basicText: Color = .dynamicColor(
        light: .Palette.B2,
        dark: .Palette.W2
    )
    
    static let tagText: Color = .dynamicColor(
        light: .Palette.B2_70,
        dark: .Palette.W3
    )
    
    static let placeholder: Color = .dynamicColor(
        light: .Palette.W4,
        dark: .Palette.W4
    )
    
    static let grayText: Color = .dynamicColor(
        light: .Palette.W4,
        dark: .Palette.W4_60
    )
    
    static let redText: Color = .dynamicColor(
        light: .Palette.TextRed,
        dark: .Palette.TextRed
    )
    
    //진함
    static let vivid: Color = .dynamicColor(
        light: .Palette.B1,
        dark: .Palette.W2
    )
    
    //소프트
    static let soft: Color = .dynamicColor(
        light: .Palette.B2_70,
        dark: .Palette.W4
    )
    
    //희미함
    static let faded: Color = .dynamicColor(
        light: .Palette.B2_15,
        dark: .Palette.W4_30
    )
    
    //MARK: - border, shadow 색
    static let basicBorder: Color = .dynamicColor(
        light: .Palette.B2_15,
        dark: .Palette.W4_30
    )
    
    static let shadow: Color = .dynamicColor(
        light: .init(white: 0, alpha: 0.3),
        dark: .init(white: 1, alpha: 0.5)
    )
    
    //MARK: - 외
    static let titleTag: Color = .dynamicColor(
        light: .Palette.W3,
        dark: .Palette.B2
    )
    
    static let titleTagText: Color = .dynamicColor(
        light: .Palette.B2_70,
        dark: .Palette.W4
    )
    
    static let colorlessTag: Color = .dynamicColor(
        light: .Palette.W2_1,
        dark: .Palette.B3
    )
    
    static let disabledButtonText: Color = .dynamicColor(
        light: .Palette.W1,
        dark: .Palette.W4_60
    )
        
    
    
}

// MARK: - TagColor 열거형
extension Color {
    enum TagColor: String, CaseIterable, Encodable, Decodable {
        case Red = "#FF9C9C"
        case Red2 = "#FFBDBD"
        case Red3 = "#FFE3DA"
        case Yellow = "#FFF56F"
        case Yellow2 = "#FFF0B8"
        case Yellow3 = "#FEFFB8"
        case Green = "#A5F8A1"
        case Green2 = "#DCF794"
        case Green3 = "#D4FDCB"
        case Mint = "#8AEBF6"
        case Mint2 = "#A6F7EA"
        case Mint3 = "#CCFFF7"
        case Blue = "#A2B4F2"
        case Blue2 = "#B3D9FF"
        case Blue3 = "#D2E8FE"
        case Purple = "#E5A6F0"
        case Purple2 = "#DEBDFF"
        case Purple3 = "#EEDEFE"
        case Pink = "#FA9BD1"
        case Pink2 = "#FFBDDE"
        case Pink3 = "#FFD9EC"
        
        var color: Color {
            let base = UIColor(hex: self.rawValue)
            return Color.dynamicColor(light: base, dark: base.withAlphaComponent(0.3))
        }
    }
}

extension Color.TagColor {
    var sortOrder: Int {
        switch self {
        case .Red: return 0
        case .Red2: return 1
        case .Red3: return 2
        case .Yellow: return 3
        case .Yellow2: return 4
        case .Yellow3: return 5
        case .Green: return 6
        case .Green2: return 7
        case .Green3: return 8
        case .Mint: return 9
        case .Mint2: return 10
        case .Mint3: return 11
        case .Blue: return 12
        case .Blue2: return 13
        case .Blue3: return 14
        case .Purple: return 15
        case .Purple2: return 16
        case .Purple3: return 17
        case .Pink: return 18
        case .Pink2: return 19
        case .Pink3: return 20
        }
    }
}
