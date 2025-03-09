//
//  CustomColor.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 12/28/24.
//

import SwiftUICore

extension Color {
    
    static let B1: Color = .init(hex: "#000000") // 사용 안 됨
    static let B2: Color = .init(hex: "#202021") // 기본 텍스트 색
    static let B2_70: Color = .init(hex: "#202021").opacity(0.70) // 태그 텍스트 색
    static let B2_15: Color = .init(hex: "#202021").opacity(0.15) // 사용 안 됨
    
    static let W1: Color = .init(hex: "#FFFFFF") // 기본 흰색
    static let W2: Color = .init(hex: "#F5F5F5") // 사용 안 됨
    static let W2_1: Color = .init(hex: "#F1F1F3") // 기본 배경색
    static let W3: Color = .init(hex: "#E3E3E7") // 사용 안 됨
    static let W4: Color = .init(hex: "#A0A0A1") // 회색이 필요한 모든 곳에
    
    static let TextRed: Color = .init(hex: "#FF5151")
    
    // HEX 값을 받아서 swiftUI Color로 바꾸는 로직
    init(hex: String) {
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&int)
        
        let red, green, blue, alpha: Double
        
        switch cleanedHex.count {
        case 3: // 3글자짜리 HEX 표현 (#RGB)
            red   = Double((int >> 8) & 0xF) / 15.0
            green = Double((int >> 4) & 0xF) / 15.0
            blue  = Double(int & 0xF) / 15.0
            alpha = 1.0
        case 6: // 6글자짜리 HEX 표현 (#RRGGBB)
            red   = Double((int >> 16) & 0xFF) / 255.0
            green = Double((int >> 8) & 0xFF) / 255.0
            blue  = Double(int & 0xFF) / 255.0
            alpha = 1.0
        case 8: // 8글자짜리 HEX 표현 (#AARRGGBB)
            alpha = Double((int >> 24) & 0xFF) / 255.0
            red   = Double((int >> 16) & 0xFF) / 255.0
            green = Double((int >> 8) & 0xFF) / 255.0
            blue  = Double(int & 0xFF) / 255.0
        default:
            red = 0
            green = 0
            blue = 0
            alpha = 1
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    // TagColor enum
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
            return Color(hex: self.rawValue)
        }
    }
}

