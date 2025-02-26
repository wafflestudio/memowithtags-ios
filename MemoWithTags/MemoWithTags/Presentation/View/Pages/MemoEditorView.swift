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

    @StateObject var keyboardManager = KeyboardManager()
    
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
                    Button(role: .destructive) {
                        viewModel.editorState = .create
                        viewModel.editorContent = ""
                        viewModel.editorTagIds = []
                        dismiss()
                    } label: {
                        Label("변경사항 삭제하기", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(Color.black)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .rotationEffect(.degrees(90))

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
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
            
            Spacer()
            
            HStack {
                switch viewModel.editorState {
                case .create:
                    Text(dateFormat(date: Date()))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.dateGray)
                        .padding(.vertical, 3)
                    
                case let .update(target):
                    Text(dateFormat(date: target.createdAt))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.dateGray)
                        .padding(.vertical, 3)
                    
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color.lockIconGray)
                        .font(.system(size: 13))
                        .opacity(target.locked ? 1 : 0)
                }
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)


            
            HFlow {
                ForEach(viewModel.getTags(from: viewModel.editorTagIds), id: \.id) { tag in
                    TagView(viewModel: viewModel, tag: tag, addXmark: true) {
                        removeTagFromSelectedTags(tag.id)
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
    
    private func removeTagFromSelectedTags(_ tagId: Int) {
        viewModel.editorTagIds.removeAll{ $0 == tagId }
    }
    
    func dateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
}
