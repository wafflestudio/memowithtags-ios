//
//  TagCollectionViewCell.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI
import Factory

struct TagView: View {
    var tag: Tag
    var xmark: Bool = false
    var onTap: (() -> Void)?
    
    @InjectedObservable(\.mainViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    @InjectedObservable(\.tagUpdateAction) private var tagUpdateAction
    
    var body: some View {
        Text(tag.name)
            .font(.pretendard(.regular, size: 13))
            .foregroundColor(Color.tagText)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(tag.color.color)
            .cornerRadius(4)
            .lineLimit(1)
            .truncationMode(.tail)
            .overlay (
                Image(systemName: "xmark")
                    .font(.system(size: 6, weight: .regular))
                    .padding(.vertical, 3)
                    .padding(.horizontal, 3)
                    .foregroundColor(Color.white)
                    .background(Color.placeholder)
                    .clipShape(Circle())
                    .offset(x: 5, y: -5)
                    .opacity(xmark ? 1 : 0), alignment: .topTrailing)
            .onTapGesture {
                onTap?()
            }
            .customContextMenu(
                preview: .tag(tag: tag), [
                    .init(icon: "pencil", title: "태그 수정") {
                        tagUpdateAction.push(.init(tag: tag))
                    },
                    .init(icon: "magnifyingglass", title: "태그로 검색") {
                        viewModel.searchContentTags = [tag.id]
                        if navigation.current != .search {
                            navigation.push(to: .search)
                        }
                    },
                    .init( icon: "trash", title: "태그 삭제", type: .delete) {
                        Task {
                            await viewModel.deleteTag(tagId: tag.id)
                        }
                    }
                ]
            )
    }
}
