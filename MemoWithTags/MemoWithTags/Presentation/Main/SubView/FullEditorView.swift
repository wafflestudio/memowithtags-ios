//
//  test.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/24/25.
//
import SwiftUI
import Flow
import Factory

struct FullEditorView: View {
    @InjectedObservable(\.editorViewModel) private var viewModel: EditorViewModel
    @InjectedObservable(\.navigation) private var navigation: Navigation

    @StateObject var keyboardManager = KeyboardManager()
    
    @State private var lastSavedContent: String = ""
    @State private var debounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        VStack(spacing: 0) {
            //MARK: - 상단 바
            HStack(spacing: 12) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(Color.soft)
                    .onTapGesture {
                        Task {
                            await viewModel.submit()
                            navigation.pop()
                        }
                    }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            //MARK: - 메모 에디터
            TextEditor(text: $viewModel.editorContent)
                .font(.pretendard(.regular, size: 16))
                .foregroundStyle(Color.basicText)
                .lineSpacing(3)
                .scrollContentBackground(.hidden)
                .background(Color.memoBackground)
                .overlay(Group { // placeholder
                    if viewModel.editorContent.isEmpty {
                        Text("메모를 작성해보세요.")
                            .font(.pretendard(.regular, size: 16))
                            .foregroundStyle(Color.placeholder)
                            .offset(x: 5, y: 8)
                    }
                }, alignment: .topLeading)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
            
            Spacer()
            
            //MARK: - 날짜, 잠금 상태 표시
            HStack {
                switch viewModel.editorState {
                case .create:
                    Text(dateFormat(date: Date()))
                        .font(.pretendard(.medium, size: 13))
                        .foregroundStyle(Color.grayText)
                        .padding(.vertical, 3)
                    
                case let .update(target):
                    Text(dateFormat(date: target.createdAt))
                        .font(.pretendard(.medium, size: 13))
                        .foregroundStyle(Color.grayText)
                        .padding(.vertical, 3)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color.grayText)
                        .opacity(target.locked ? 1 : 0)
                }
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            //MARK: - 메모 내 태그들
            HFlow {
                ForEach(viewModel.getTags(from: viewModel.editorTagIds), id: \.id) { tag in
                    TagView(viewModel: viewModel, tag: tag, addXmark: true) {
                        removeTagFromSelectedTags(tag.id)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if keyboardManager.currentHeight > 0 {
                EditingTagListView(viewModel: viewModel)
            }
        }
        .background(Color.memoBackground)
        .navigationBarBackButtonHidden()
        .onAppear {
            lastSavedContent = viewModel.editorContent
        }
        .onChange(of: viewModel.editorContent) {
            debounceAutoSave()
        }
        .onDisappear {
            debounceWorkItem?.cancel()
        }
    }
    
    private func removeTagFromSelectedTags(_ tagId: Int) {
        viewModel.editorTagIds.removeAll{ $0 == tagId }
    }
    
    private func dateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
    
    private func debounceAutoSave() {
        debounceWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            Task {
                await saveChanges()
            }
        }

        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }
    
    private func saveChanges() async {
        guard viewModel.editorContent != lastSavedContent else { return }

        await viewModel.save()
        lastSavedContent = viewModel.editorContent
    }
}
