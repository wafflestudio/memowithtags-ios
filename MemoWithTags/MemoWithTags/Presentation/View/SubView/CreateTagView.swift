//
//  CreateTagView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/10/25.
//

import SwiftUI

struct CreateTagView: View {
    @Binding var searchText: String
    @Binding var randomColor: Color.TagColor
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(searchText)
                .font(.pretendard(.regular, size: 14))
                .foregroundColor(Color.tagTextColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(randomColor.color)
                .cornerRadius(4)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text("만들기")
                .font(.pretendard(.regular, size: 14))
        }
    }
}
