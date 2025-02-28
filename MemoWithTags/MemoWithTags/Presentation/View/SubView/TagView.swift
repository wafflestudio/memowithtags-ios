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
            .customContextMenu(isPresented: $isMenuVisible) {
                AnyView(
                    Text(tag.name)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color.tagTextColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .background(tag.color.color)
                        .cornerRadius(4)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .scaleEffect(1.4)
                )
            } contextmenu: {
                AnyView(
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("이 태그로 검색하기")
                            Spacer()
                            Image(systemName: "magnifyingglass")
                        }
                        .onTapGesture {
                            viewModel.clearSearch()
                            viewModel.searchBarSelectedTagIds.append(tag.id)
                            // 현재 뷰가 search가 아닌 경우에만 searchPage로 이동
                            if viewModel.appState.navigation.current != .search {
                                viewModel.appState.navigation.push(to: .search)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("태그 수정")
                            Spacer()
                            Image(systemName: "pencil")
                        }
                        .onTapGesture {
                            isUpdating = true
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("태그 삭제")
                            Spacer()
                            Image(systemName: "trash")
                        }
                        .onTapGesture {
                            Task {
                                await viewModel.deleteTag(tagId: tag.id)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.memoBackgroundWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .frame(width: 250)
                )
            }
            .sheet(isPresented: $isUpdating, onDismiss: {
                isUpdating = false
            }) {
                UpdateTagView(viewModel: viewModel, tag: tag)
            }
    }
}
