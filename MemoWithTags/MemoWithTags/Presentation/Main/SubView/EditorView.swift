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
    
    @StateObject private var keyboard = KeyboardManager()

    var editorEmpty: Bool { viewModel.editContent.isEmpty && viewModel.editTagList.isEmpty }
        
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
                
                if !viewModel.editTagList.isEmpty {
                    HFlow {
                        ForEach(viewModel.editTagList.toTags(from: viewModel.tags), id: \.id) { tag in
                            TagView(tag: tag, xmark: true) {
                                viewModel.editTagList.removeAll { $0 == tag.id }
                            }
                        }
                    }
                }

                if !editorEmpty {
                    HStack(spacing: 0) {
                        Image(systemName: "arrow.down.left.and.arrow.up.right")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color.placeholder)
                            .onTapGesture {
                                navigation.push(to: .fullEditor(id: -1))
                            }
                        
                        Spacer()
                        
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.vivid)
                            .frame(width: 25, height: 27, alignment: .top)
                            .onTapGesture {
                                Task {
                                    let tempContent = viewModel.editContent
                                    let tempTagList = viewModel.editTagList
                                    hideKeyboard()
                                    viewModel.editContent = ""
                                    viewModel.editTagList = []
                                    viewModel.scrollTo(memoID: nil)
                                    await viewModel.createMemo(content: tempContent, tagIds: tempTagList, locked: false)
                                }
                            }
                    }
                }
            }
            .padding(.vertical, editorEmpty ? 6 : 12)
            .padding(.horizontal, 17)
            .background(Color.editorBackground)
            .cornerRadius(14)
            .matchedTransitionSource(id: -1, in: navigation.namespace)   
            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 1.5)
            .padding(.horizontal, 7)
            .padding(.bottom, 8)
            
            if keyboard.currentHeight > 0 {
                TagEditorView()
            }
        }
    }
}
