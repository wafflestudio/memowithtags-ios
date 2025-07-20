//
//  EditorVIew.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/27/25.
//

import SwiftUI
import Flow
import Factory
import WebKit

struct EditorView: View {
    @InjectedObservable(\.mainViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    @InjectedObservable(\.expandAction) private var expandAction
    
    @StateObject private var keyboard = KeyboardManager()

    var editorEmpty: Bool { viewModel.editContent.isEmpty && viewModel.editTags.isEmpty }
    
    @State private var recommendingTask: Task<Void, Never>? = nil
    @State private var showCancelAlert: Bool = false
    @State private var showRecommendingPrompt: Bool = false
    @State private var animationWorkItem: DispatchWorkItem?
        
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    PlainEditor(text: $viewModel.editContent)
                    
                    if editorEmpty {
                       Image(systemName: "square.and.pencil")
                           .font(.system(size: 20))
                           .foregroundColor(Color.vivid)
                           .frame(width: 25, height: 27, alignment: .top)
                    }
                }
                
                if !viewModel.editTags.isEmpty {
                    HFlow {
                        ForEach(viewModel.tags(for: viewModel.editTags) , id: \.id) { tag in
                            TagView(tag: tag, xmark: true) {
                                viewModel.editTags.removeAll { $0 == tag.id }
                            }
                        }
                    }
                }

                
                if !editorEmpty {
                    HStack(spacing: 0) {
                        switch viewModel.editState {
                        case .create:
                            Image(systemName: "arrow.down.left.and.arrow.up.right")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(Color.placeholder)
                                .onTapGesture {
                                    expandAction.push(.init(content: viewModel.editContent, tags: viewModel.editTags, editState: .create))
                                }
                        
                            Spacer()

                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.vivid)
                                .frame(width: 25, height: 27, alignment: .top)
                                .onTapGesture {
                                    Task {
                                        await viewModel.saveMemo(content: viewModel.editContent, tags: viewModel.editTags, editState: .create)
                                    }
                                }
                            
                        case .update(let memo):
                            Image(systemName: "arrow.down.left.and.arrow.up.right")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(Color.placeholder)
                                .onTapGesture {
                                    expandAction.push(.init(content: viewModel.editContent, tags: viewModel.editTags, editState: .update(memo: memo)))
                                }
                            
                            Spacer()
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.white)
                                .padding(0)
                                .frame(width: 24, height: 24, alignment: .center)
                                .background(Color.redText)
                                .cornerRadius(20)
                                .padding(.trailing, 12)
                                .onTapGesture {
                                    showCancelAlert = true
                                }
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color(UIColor.Palette.W2_1))
                                .padding(0)
                                .frame(width: 24, height: 24, alignment: .center)
                                .background(Color(UIColor.Palette.B2_70))
                                .cornerRadius(20)
                                .onTapGesture {
                                    Task {
                                        await viewModel.saveMemo(content: viewModel.editContent, tags: viewModel.editTags, editState: .update(memo: memo))
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.vertical, editorEmpty ? 6 : 12)
            .padding(.horizontal, 17)
            .background(Color.editorBackground)
            .cornerRadius(14)
            .matchedTransitionSource(id: "editor", in: expandAction.namespace)
            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 1.5)
            .overlay(recommendingOverlay, alignment: .topTrailing)
            .padding(.horizontal, 7)
            .padding(.bottom, 8)
            .onChange(of: viewModel.editTags) {
                recommendingTask?.cancel()
                
                recommendingTask = Task {
                    await viewModel.recommendMemos()
                }
            }
            .alert("수정 취소", isPresented: $showCancelAlert) {
                Button("확인", role: .destructive) {
                    viewModel.editContent = ""
                    viewModel.editTags = []
                    viewModel.editState = .create
                }
                Button("취소", role: .cancel) {
                }
            } message: {
                Text("해당 메모 수정을 취소하시겠습니까?")
            }
            
            if keyboard.currentHeight > 0 {
                TagEditorView(selectedTags: $viewModel.editTags)
            }
        }
    }
    
    private func promptAnimation(togle: Bool) {
        animationWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            withAnimation(.spring) {
                showRecommendingPrompt = togle
            }
        }

        animationWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: togle ? .now() : .now() + 3 , execute: workItem)
    }
    
    private var recommendingPrompt: some View {
            HStack {
                if (showRecommendingPrompt) {
                    Text("\(viewModel.recommendingMemoIds.count)개의 메모를 추천합니다.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.vivid.opacity(showRecommendingPrompt ? 1 : 0))
                        .padding(.leading, 10)
                        .padding(.trailing, 5)
                        .onAppear {
                            promptAnimation(togle: false)
                        }
                }
                
                Text("\(viewModel.highlightingMemoIndex == -1 ? "-" : String(viewModel.highlightingMemoIndex + 1)) / \(viewModel.recommendingMemoIds.count)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.vivid)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.memoBackground)
                    )
            }
            .background(Color.background)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .onAppear {
                promptAnimation(togle: true)
            }
            .onDisappear {
                animationWorkItem?.cancel()
                showRecommendingPrompt = false
            }
        }
        
        private var recommendingOverlay: some View {
            Group {
                if !viewModel.recommendingMemoIds.isEmpty {
                    HStack(spacing: 8) {
                        recommendingPrompt
                        
                        HStack(spacing: 10) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.vivid)
                                .frame(width: 27, height: 27)
                                .background(Color.memoBackground)
                                .clipShape(
                                    Circle()
                                )
                                .onTapGesture {
                                    if viewModel.highlightingMemoIndex < viewModel.recommendingMemoIds.count - 1 {
                                        viewModel.highlightingMemoIndex += 1
                                        viewModel.scrollTo(memoID: viewModel.recommendingMemoIds[viewModel.highlightingMemoIndex])
                                    }
                                }
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.vivid)
                                .frame(width: 27, height: 27)
                                .background(Color.memoBackground)
                                .clipShape(
                                    Circle()
                                )
                                .onTapGesture {
                                    if viewModel.highlightingMemoIndex > 0 {
                                        viewModel.highlightingMemoIndex -= 1
                                        viewModel.scrollTo(memoID: viewModel.recommendingMemoIds[viewModel.highlightingMemoIndex])
                                    }
                                }
                        }
                        .background(Color.background)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 20)
                        )
                    }
                }
            }
            .offset(x: -11, y: -35)
            .shadow(color: Color.shadow, radius: 3, x: 0, y: 1)
        }
}
