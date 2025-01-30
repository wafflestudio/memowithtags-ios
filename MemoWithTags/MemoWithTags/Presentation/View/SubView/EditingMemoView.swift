//
//  EditingMemoView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/6/25.
//

import SwiftUI
import Flow
import RichTextKit

@available(iOS 18.0, *)
struct EditingMemoView: View {
    @ObservedObject var viewModel: MainViewModel
    
    @Namespace var namespace
    
    @State var dynamicHeight: CGFloat = 40
    @StateObject var context = RichTextContext()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 메모글 쓰는 곳
            DynamicHeightTextEditor(
                text: $viewModel.editorContent,
                maxHeight: 100
            )
            
            // 메모에 넣은 태그들
            HFlow {
                ForEach(viewModel.editorTags, id: \.id) { tag in
                    TagView(viewModel: viewModel, tag: tag, addXmark: true) {
                        removeTagFromSelectedTags(tag)
                    }
                }
            }
            
            HStack {
                switch viewModel.editorState {
                case .create: // create 모드일 때
                    Spacer()
                    
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .onTapGesture {
                            Task {
                                await viewModel.submit()
                            }
                        }

                case .update: // 업데이트 모드일 때
                    Image(systemName: "arrow.down.left.and.arrow.up.right")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.dateGray)
                        .onTapGesture {
                            viewModel.appState.navigation.push(to: .memoEditor(namespace: namespace, id: "zoom"))
                        }
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .regular))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 5)
                        .foregroundColor(.memoBackgroundWhite)
                        .background(Color.highlightRed)
                        .clipShape(Circle())
                        .onTapGesture {
                            viewModel.editorState = .create
                            viewModel.editorContent = ""
                            viewModel.editorTags = []
                        }
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .regular))
                        .padding(.vertical, 3.5)
                        .padding(.horizontal, 4)
                        .foregroundColor(.black)
                        .background(Color.backgroundGray)
                        .clipShape(Circle())
                        .onTapGesture {
                            Task {
                                await viewModel.submit()
                            }
                        }
                }
                
            }
        }
        .padding(.top, 9)
        .padding(.bottom, 12)
        .padding(.horizontal, 17)
        .background(Color.memoBackgroundWhite)
        .cornerRadius(14)
        .matchedTransitionSource(id: "zoom", in: namespace)
        .padding(.horizontal, 7)
        .padding(.bottom, 8)
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 2)
    }
    
    
    private func removeTagFromSelectedTags(_ tag: Tag) {
        viewModel.editorTags.removeAll { $0.id == tag.id }
    }
}
