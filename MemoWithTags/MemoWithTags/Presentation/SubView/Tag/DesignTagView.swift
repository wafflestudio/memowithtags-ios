//
//  DesignTagView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/14/25.
//

import SwiftUI

struct DesignTagView: View {
    let text: String
    let fontSize: CGFloat
    let backGroundColor: Color
    let onTap: (() -> Void)?
    
    let fontWeight: Font.Weight = .regular
    let horizontalPadding: CGFloat = 6
    let verticalPadding: CGFloat = 4
    let cornerRadius: CGFloat = 4
    
    var body: some View {
        Text(text)
            .font(.pretendard(fontWeight, size: fontSize))
            .foregroundStyle(Color.tagText)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backGroundColor)
            .cornerRadius(cornerRadius)
            .onTapGesture {
                onTap?()
            }
    }
}
