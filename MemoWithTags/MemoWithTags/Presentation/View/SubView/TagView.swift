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
            .foregroundColor(Color.B2_70)
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
                    .foregroundColor(.W1)
                    .background(Color.W4)
                    .clipShape(Circle())
                    .offset(x: 5, y: -5)
                    .opacity(addXmark ? 1 : 0), alignment: .topTrailing)
            .onTapGesture {
                onTap?()
            }
            .customContextMenu {
                AnyView(
                    VStack(alignment: .leading, spacing: 10) {
                        Button("이 태그로 검색하기", role: .none) {
                            viewModel.clearSearch()
                            viewModel.searchBarSelectedTagIds.append(tag.id)
                            // 현재 뷰가 search가 아닌 경우에만 searchPage로 이동
                            if viewModel.appState.navigation.current != .search {
                                viewModel.appState.navigation.push(to: .search)
                            }
                        }
                        
                        Button("태그 수정", role: .none) {
                            isUpdating = true
                        }
                        
                        Button("태그 삭제", role: .none) {
                            Task {
                                await viewModel.deleteTag(tagId: tag.id)
                            }
                        }
                    }
                )
            }
            .sheet(isPresented: $isUpdating, onDismiss: {
                isUpdating = false
            }) {
                UpdateTagView(viewModel: viewModel, tag: tag)
            }
    }
}
