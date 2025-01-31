//
//  test.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/24/25.
//
import SwiftUI
import RichTextKit
import Flow

struct MemoEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MainViewModel
    @StateObject private var keyboardManager = KeyboardManager()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(Color.black)
                    .onTapGesture {
                        Task {
                            dismiss()
                            await viewModel.submit()
                        }
                    }
                
                Spacer()
                
                Menu {
                    Button {
                    } label: {
                        Label("매모 잠그기", systemImage: "lock")
                    }
                    
                    Button(role: .destructive) {
                        viewModel.editorState = .create
                        viewModel.editorContent = ""
                        viewModel.editorTags = []
                        dismiss()
                    } label: {
                        Label("변경사항 삭제하기", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 19, weight: .regular))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(Color.black)
                }
        
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            
            TextEditor(text: $viewModel.editorContent)
                .overlay(Group { // placeholder
                    if viewModel.editorContent.isEmpty {
                        Text("메모를 작성해보세요.")
                            .foregroundStyle(Color.dividerGray)
                            .offset(x: 5, y: 10)
                    }
                }, alignment: .topLeading)
                .border(.black)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
            
            Spacer()
            
            HFlow {
                ForEach(viewModel.editorTags, id: \.id) { tag in
                    TagView(viewModel: viewModel, tag: tag, addXmark: true) {
                        removeTagFromSelectedTags(tag)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            
            if keyboardManager.currentHeight > 0 {
                EditingTagListView(viewModel: viewModel)
            }
            
        }
    }
    
    private func removeTagFromSelectedTags(_ tag: Tag) {
        viewModel.editorTags.removeAll { $0.id == tag.id }
    }
    
    @ViewBuilder private func EditIcon(icon: String, selected: Bool, click: @escaping () -> Void) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(selected ? .black : .tabBarNotSelectecdIconGray)
            .onTapGesture {
                click()
            }
    }
}
