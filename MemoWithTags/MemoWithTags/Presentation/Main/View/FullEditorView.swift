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
    let initContent: String
    let initTags: [TagID]
    let editState: EditState
    
    @InjectedObservable(\.mainViewModel) private var viewModel: MainViewModel
    @InjectedObservable(\.navigationState) private var navigation

    @StateObject private var keyboard = KeyboardManager()
    @Environment(\.dismiss) var dismiss
    
    @State private var content: String = ""
    @State private var tags: [TagID] = []

    var body: some View {
        VStack(spacing: 0) {
            //MARK: - 상단 바
            HStack(spacing: 12) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(Color.soft)
                    .onTapGesture {
                        Task {
                            dismiss()
                            hideKeyboard()
                            await viewModel.saveMemo(content: content, tags: tags, editState: editState)
                        }
                    }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            //MARK: - 메모 에디터
            TextEditor(text: $content)
                .font(.pretendard(.regular, size: 16))
                .foregroundStyle(Color.basicText)
                .lineSpacing(3)
                .scrollContentBackground(.hidden)
                .background(Color.memoBackground)
                .overlay(Group { // placeholder
                    if content.isEmpty {
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
                switch editState {
                case .create:
                    Text(dateFormat(date: Date()))
                        .font(.pretendard(.medium, size: 13))
                        .foregroundStyle(Color.grayText)
                        .padding(.vertical, 3)
                    
                case let .update(memo):
                    Text(dateFormat(date: memo.createdAt))
                        .font(.pretendard(.medium, size: 13))
                        .foregroundStyle(Color.grayText)
                        .padding(.vertical, 3)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color.grayText)
                        .opacity(memo.locked ? 1 : 0)
                }
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            //MARK: - 메모 내 태그들
            HFlow {
                ForEach(tags.toTags(from: viewModel.tags), id: \.id) { tag in
                    TagView(tag: tag, xmark: true) {
                        tags.removeAll { $0 == tag.id }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if keyboard.currentHeight > 0 {
                TagEditorView(selectedTags: $tags)
            }
        }
        .background(Color.memoBackground)
        .navigationBarBackButtonHidden()
        .onChange(of: content) {
            Task {
                await viewModel.saveMemo(content: content, tags: tags, editState: editState, auto: true)
            }
        }
        .onChange(of: tags) {
            Task {
                await viewModel.saveMemo(content: content, tags: tags, editState: editState, auto: true)
            }
        }
        .onAppear {
            self.content = initContent
            self.tags = initTags
        }
    }
    
    private func dateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
}
