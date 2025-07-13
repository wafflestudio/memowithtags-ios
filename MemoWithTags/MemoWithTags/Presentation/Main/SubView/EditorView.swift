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
    
    @State private var showCancelAlert: Bool = false
        
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
                        ForEach(viewModel.editTags.toTags(from: viewModel.tags), id: \.id) { tag in
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
            .padding(.horizontal, 7)
            .padding(.bottom, 8)
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
}
