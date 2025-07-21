//
//  EditableTagView.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/7/25.
//

import SwiftUI

struct EditableTagView: View {
    let tag: Tag
    let star: Bool
    let onTap: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 2) {
            if star {
                Image(.starFilledIcon)
                    .resizable()
                    .frame(width: 9, height: 9)
                    .foregroundStyle(Color.basicText)
            }
            
            Text(tag.name)
                .font(.pretendard(.regular, size: 13))
                .foregroundStyle(Color.tagText)
            
            Image(systemName: "pencil")
                .font(.system(size: 13))
                .foregroundColor(Color.basicText)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(tag.color.color)
        .cornerRadius(4)
        .onTapGesture {
            onTap?()
        }
    }
}
