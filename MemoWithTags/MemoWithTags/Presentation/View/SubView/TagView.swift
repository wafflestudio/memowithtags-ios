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
    
    var tag: Tag
    var addXmark: Bool = false
    var onTap: (() -> Void)?
    
    var body: some View {
        Text(tag.name)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(Color.tagTextColor)
            .padding(.horizontal, 7)
            .padding(.vertical, 1)
            .background(tag.color.color)
            .cornerRadius(4)
            .lineLimit(1)
            .truncationMode(.tail)
            .overlay (
                Image(systemName: "xmark")
                    .font(.system(size: 5, weight: .regular))
                    .padding(.vertical, 2.5)
                    .padding(.horizontal, 2.5)
                    .foregroundColor(.memoBackgroundWhite)
                    .background(Color.dateGray)
                    .clipShape(Circle())
                    .offset(x: 5, y: -5)
                    .opacity(addXmark ? 1 : 0), alignment: .topTrailing)
            .onTapGesture {
                onTap?()
            }
            .contextMenu {
                Button(action: {
                    viewModel.clearSearch()
                    viewModel.searchBarSelectedTags.append(tag)
                    // 현재 뷰가 search가 아닌 경우에만 searchPage로 이동
                    if viewModel.appState.navigation.current != .search {
                        viewModel.appState.navigation.push(to: .search)
                    }
                }) {
                    Label("이 태그로 검색하기", systemImage: "magnifyingglass")
                }
                
                Button {
                    isUpdating = true
                } label: {
                    Label("수정", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    Task {
                        await viewModel.deleteTag(tagId: tag.id)
                    }
                } label: {
                    Label("삭제", systemImage: "trash")
                }
            }
            .sheet(isPresented: $isUpdating, onDismiss: {
                isUpdating = false
            }) {
                UpdateTagView(viewModel: viewModel, tag: tag)
            }
    }
}
