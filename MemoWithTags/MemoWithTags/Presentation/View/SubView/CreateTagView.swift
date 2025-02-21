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
            Text("Create")
                .font(.custom("Pretendard", size: 16))
            
            Text(searchText)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.tagTextColor)
                .padding(.horizontal, 7)
                .padding(.vertical, 1)
                .background(randomColor.color)
                .cornerRadius(4)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}
