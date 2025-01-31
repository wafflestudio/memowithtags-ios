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
    @State private var showEditor: Bool = false
    
    @State private var memoEditingTask: Task<Void, Never>? = nil
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 메모글 쓰는 곳
            DynamicHeightTextEditor(text: $viewModel.editorContent, maxHeight: 100)
                .focused($isFocused)
                .onChange(of: viewModel.editorContent) {
                    // 실행하고 있는 searchTask를 종료
                    memoEditingTask?.cancel()
                    
                    // 새로운 searchTask 생성
                    memoEditingTask = Task {
                        // 1초 기다리기
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        
                        if viewModel.editorContent.isEmpty {
                            viewModel.aiRecommendation = false
                        } else {
                            viewModel.aiRecommendation = true
                            viewModel.recommendMemosAndTags()
                        }
     
                    }
                }
            
            // 메모에 넣은 태그들
            HFlow {
                ForEach(viewModel.editorTags, id: \.id) { tag in
                    TagView(viewModel: viewModel, tag: tag, addXmark: true) {
                        removeTagFromSelectedTags(tag)
                    }
                }
            }
            .padding(.top, 6)
            
            //editor 밑에 버튼들
            HStack {
                switch viewModel.editorState {
                case .create: // create 모드일 때
                    Image(systemName: "arrow.down.left.and.arrow.up.right")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.dateGray)
                        .onTapGesture {
                            showEditor = true
                        }
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#FF9C9C"))
                        .onTapGesture {
                            isFocused = false
                            viewModel.aiRecommendation = false
                            viewModel.editorState = .create
                            viewModel.editorContent = ""
                            viewModel.editorTags = []
                        }
                    
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .onTapGesture {
                            Task {
                                isFocused = false
                                await viewModel.submit()
                            }
                        }
                        .padding(.bottom, 3)

                case .update: // 업데이트 모드일 때
                    Image(systemName: "arrow.down.left.and.arrow.up.right")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.dateGray)
                        .onTapGesture {
                            showEditor = true
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
                            isFocused = false
                            viewModel.aiRecommendation = false
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
            .padding(.top, 6)
        }
        .padding(.top, 9)
        .padding(.bottom, 12)
        .padding(.horizontal, 17)
        .background(Color.memoBackgroundWhite)
        .cornerRadius(14)
        .matchedTransitionSource(id: "zoom", in: namespace)
        .fullScreenCover(isPresented: $showEditor) {
            MemoEditorView(viewModel: viewModel)
                .navigationTransition(.zoom(sourceID: "zoom", in: namespace))
                .interactiveDismissDisabled()
        }
        .padding(.horizontal, 7)
        .padding(.bottom, 8)
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 1.5)
        .overlay(Group {
            HStack(spacing: 18) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 14, weight: .regular))
                    .background(
                        Circle()
                            .fill(Color.backgroundGray)
                            .frame(width: 27, height: 27)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 1)
                    .onTapGesture {
                        if viewModel.scrollTarget < viewModel.recommendingMemos.count {
                            viewModel.scrollTarget += 1
                        }
                    }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .regular))
                    .background(
                        Circle()
                            .fill(Color.backgroundGray)
                            .frame(width: 27, height: 27)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 1)
                    .onTapGesture {
                        if viewModel.scrollTarget > 1 {
                            viewModel.scrollTarget -= 1
                        }
                    }
            }
        }.offset(x: -20, y: -26).opacity(viewModel.aiRecommendation ? 1 : 0)
        , alignment: .topTrailing)
        .onChange(of: viewModel.recommendingMemos) {
            viewModel.scrollTarget = 0
        }
    }
    
    
    private func removeTagFromSelectedTags(_ tag: Tag) {
        viewModel.editorTags.removeAll { $0.id == tag.id }
    }
}
