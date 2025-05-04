//
//  EditingMemoView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/6/25.
//

import SwiftUI
import Flow

struct EditingMemoView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var memoEditingTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            //MARK: - 메모글 쓰는 곳
            DynamicHeightTextEditor(text: $viewModel.editorContent)
                .overlay (
                    Group {
                        if viewModel.editorContent.isEmpty && viewModel.editorTagIds.isEmpty {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20))
                                .foregroundColor(Color.vivid)
                                .frame(width: 25, height: 27, alignment: .top)
                                .onTapGesture {
                                    Task {
                                        await viewModel.submit()
                                    }
                                }
                        }
                    }
                    , alignment: .trailing
                )
            
            //MARK: - 메모에 넣은 태그들
            if !viewModel.editorTagIds.isEmpty {
                HFlow {
                    ForEach(viewModel.getTags(from: viewModel.editorTagIds), id: \.id) { tag in
                        TagView(viewModel: viewModel, tag: tag, addXmark: true) {
                            removeTagFromSelectedTags(tag.id)
                        }
                    }
                }
            }
            
            //MARK: - editor 아래 버튼들
            if !(viewModel.editorContent.isEmpty && viewModel.editorTagIds.isEmpty) {
                HStack {
                    switch viewModel.editorState {
                    case .create: // create 모드일 때
                        Image(systemName: "arrow.down.left.and.arrow.up.right")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color.placeholder)
                            .onTapGesture {
                                viewModel.appState.navigation.push(to: .memoEditor)
                            }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .resizable()
                            .frame(width: 16, height: 6)
                            .padding(.top, 9)
                            .foregroundStyle(Color.placeholder)
                            .onTapGesture {
                                viewModel.hideKeyboard()
                            }
                            
                        
                        Spacer()
                        
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.vivid)
                            .frame(width: 25, height: 27, alignment: .top)
                            .onTapGesture {
                                Task {
                                    await viewModel.submit()
                                }
                            }
                        
                    case .update: // 업데이트 모드일 때
                        Image(systemName: "arrow.down.left.and.arrow.up.right")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color.placeholder)
                            .onTapGesture {
                                viewModel.appState.navigation.push(to: .memoEditor)
                            }
                        
                        Spacer()
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color.white)
                            .padding(0)
                            .frame(width: 24, height: 24, alignment: .center)
                            .background(Color.TagColor.Red2.color)
                            .cornerRadius(20)
                            .onTapGesture {
                                viewModel.editorState = .create
                                viewModel.editorContent = ""
                                viewModel.editorTagIds = []
                            }
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.black)
                            .padding(0)
                            .frame(width: 24, height: 24, alignment: .center)
                            .background(Color(UIColor.Palette.W2_1))
                            .cornerRadius(20)
                            .onTapGesture {
                                Task {
                                    await viewModel.submit()
                                }
                            }
                    }
                }
            }
        }
        .padding(.vertical, viewModel.editorContent.isEmpty && viewModel.editorTagIds.isEmpty ? 6 : 12)
        .padding(.horizontal, 17)
        .background(Color.editorBackground)
        .cornerRadius(14)
        .padding(.horizontal, 7)
        .padding(.bottom, 8)
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 1.5)
        .overlay(recommendingOverlay, alignment: .topTrailing)
        // 나중에 content로도 recommend를 할 때 사용한다.
        /*
         .onChange(of: viewModel.editorContent) {
         // 실행하고 있는 recommendingTask를 종료
         memoEditingTask?.cancel()
         
         // 새로운 recommendingTask 생성
         memoEditingTask = Task {
         do {
         try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 debounce
         await viewModel.recommendMemos()
         } catch {
         // 취소된 경우 아무 작업도 하지 않아도 된다.
         }
         }
         }
         */
        .onChange(of: viewModel.editorTagIds) {
            // 실행하고 있는 recommendingTask를 종료
            memoEditingTask?.cancel()
            
            // 새로운 recommendingTask 생성
            memoEditingTask = Task {
                await viewModel.recommendMemos()
            }
        }
    }
    
    private func removeTagFromSelectedTags(_ tagId: Int) {
        viewModel.editorTagIds.removeAll{ $0 == tagId }
    }
    
    // overlay view를 computed property로 따로 분리
    private var recommendingOverlay: some View {
        Group {
            if !viewModel.recommendingMemoIds.isEmpty {
                HStack(spacing: 12) {
                    Text("\(viewModel.highlightingMemoIndex == -1 ? "-" : String(viewModel.highlightingMemoIndex + 1)) / \(viewModel.recommendingMemoIds.count)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.vivid)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            Rectangle()
                                .fill(Color.memoBackground)
                                .cornerRadius(20)
                        )
                        .shadow(color: Color.shadow, radius: 3, x: 0, y: 1)
                    
                    // ZStack을 사용하여 두 동그라미 사이 영역을 완전히 채움
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.background)
                            .frame(width: 60, height: 27) // 일일이 때려맞춤
                            .offset(x: -5.5 ) // 일일이 때려 맞춤
                            .shadow(color: Color.shadow, radius: 3, x: 0, y: 1)
                            
                        
                        HStack(spacing: 18) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.vivid)
                                .background(
                                    Circle()
                                        .fill(Color.memoBackground)
                                        .frame(width: 27, height: 27)
                                )
                                .onTapGesture {
                                    if viewModel.highlightingMemoIndex < viewModel.recommendingMemoIds.count - 1 {
                                        viewModel.highlightingMemoIndex += 1
                                    }
                                }
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.vivid)
                                .background(
                                    Circle()
                                        .fill(Color.memoBackground)
                                        .frame(width: 27, height: 27)
                                )
                                .onTapGesture {
                                    if viewModel.highlightingMemoIndex > -1 {
                                        viewModel.highlightingMemoIndex -= 1
                                    }
                                }
                        }
                        
                        
                    }
                }
            }
        }
        .offset(x: -20, y: -36)
    }
    
}
