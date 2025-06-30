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
    
    @State private var content: String = ""
    @State private var contentTagList: [TagID] = []
    var editorEmpty: Bool { content.isEmpty && contentTagList.isEmpty }
        
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    PlainEditor(text: $content)
                    
                    if editorEmpty {
                       Image(systemName: "square.and.pencil")
                           .font(.system(size: 20))
                           .foregroundColor(Color.vivid)
                           .frame(width: 25, height: 27, alignment: .top)
                    }
                }
                
                if !contentTagList.isEmpty {
                    HFlow {
                        ForEach(contentTagList.toTags(from: viewModel.tags), id: \.id) { tag in
                            TagView(tag: tag, xmark: true) {
                                contentTagList.removeAll { $0 == tag.id }
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
                                    let tempContent = content
                                    let tempTagList = contentTagList
                                    hideKeyboard()
                                    content = ""
                                    contentTagList = []
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
                TagEditorView(selectList: $contentTagList)
            }
        }
    }
}
