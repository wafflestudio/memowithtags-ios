////
////  TagCollectionViewCell.swift
////  MemoWithTags
////
////  Created by Swimming Ryu on 1/5/25.
////
//
//import SwiftUI
//import Factory
//
//struct TagView: View {
//    @InjectedObservable(\.tagViewModel) private var viewModel: TagViewModel
//
//    @State private var isUpdating: Bool = false
//    @State private var isMenuVisible = false
//    
//    var tag: Tag
//    var xmark: Bool = false
//    var onTap: (() -> Void)?
//    
//    var body: some View {
//        Text(tag.name)
//            .font(.pretendard(.regular, size: 13))
//            .foregroundColor(Color.tagText)
//            .padding(.horizontal, 6)
//            .padding(.vertical, 4)
//            .background(tag.color.color)
//            .cornerRadius(4)
//            .lineLimit(1)
//            .truncationMode(.tail)
//            .overlay (
//                Image(systemName: "xmark")
//                    .font(.system(size: 6, weight: .regular))
//                    .padding(.vertical, 3)
//                    .padding(.horizontal, 3)
//                    .foregroundColor(Color.white)
//                    .background(Color.placeholder)
//                    .clipShape(Circle())
//                    .offset(x: 5, y: -5)
//                    .opacity(xmark ? 1 : 0), alignment: .topTrailing)
//            .onTapGesture {
//                onTap?()
//            }
//            .customContextMenu(
//                appState: viewModel.appState,
//                type: .tag(tag: tag),
//                menuItems: [
//                    .init(title: "태그 수정", icon: "pencil") {
//                        isUpdating = true
//                    },
//                    .init(title: "태그로 검색", icon: "magnifyingglass") {
//                        viewModel.clearSearch()
//                        viewModel.searchBarSelectedTagIds.append(tag.id)
//                        if viewModel.appState.navigation.current != .search {
//                            viewModel.appState.navigation.push(to: .search)
//                        }
//                    },
//                    .init(title: "태그 삭제", icon: "trash", type: .delete) {
//                        Task {
//                            await viewModel.deleteTag(tagId: tag.id)
//                        }
//                    }
//                ]
//            )
//            .sheet(isPresented: $isUpdating, onDismiss: {
//                isUpdating = false
//            }) {
//                TagEditorView(tag: tag)
//            }
//    }
//}
