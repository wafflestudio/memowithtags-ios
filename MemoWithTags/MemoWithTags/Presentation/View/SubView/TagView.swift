//
//  TagCollectionViewCell.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI

struct TagView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isUpdating: Bool = false
    @State private var isMenuVisible = false
    
    var tag: Tag
    var addXmark: Bool = false
    var onTap: (() -> Void)?
    
    var body: some View {
        Text(tag.name)
            .font(.pretendard(.regular, size: 13))
            .foregroundColor(Color.tagTextColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(tag.color.color)
            .cornerRadius(4)
            .lineLimit(1)
            .truncationMode(.tail)
            .overlay (
                Image(systemName: "xmark")
                    .font(.system(size: 6, weight: .regular))
                    .padding(.vertical, 3)
                    .padding(.horizontal, 3)
                    .foregroundColor(.memoBackgroundWhite)
                    .background(Color.dateGray)
                    .clipShape(Circle())
                    .offset(x: 5, y: -5)
                    .opacity(addXmark ? 1 : 0), alignment: .topTrailing)
            .onTapGesture {
                onTap?()
            }
            .customContextMenu(appState: viewModel.appState) {
                Text("hi")
            }
            .sheet(isPresented: $isUpdating, onDismiss: {
                isUpdating = false
            }) {
                UpdateTagView(viewModel: viewModel, tag: tag)
            }
    }
}
