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
    @InjectedObservable(\.mainViewModel) private var viewModel: MainViewModel
    @InjectedObservable(\.navigationState) private var navigation

    @StateObject private var keyboard = KeyboardManager()
    
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
            TextEditor(text: $viewModel.editContent)
                .font(.pretendard(.regular, size: 16))
                .foregroundStyle(Color.basicText)
                .lineSpacing(3)
                .scrollContentBackground(.hidden)
                .background(Color.memoBackground)
                .overlay(Group { // placeholder
                    if viewModel.editContent.isEmpty {
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
                switch viewModel.editState {
                case .creating:
                    Text(dateFormat(date: Date()))
                        .font(.pretendard(.medium, size: 13))
                        .foregroundStyle(Color.grayText)
                        .padding(.vertical, 3)
                    
                case let .updating(target):
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
                ForEach(viewModel.editTagList.toTags(from: viewModel.tags), id: \.id) { tag in
                    TagView(tag: tag, xmark: true) {
                        viewModel.editTagList.removeAll { $0 == tag.id }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if keyboard.currentHeight > 0 {
                TagEditorView(selectList: $viewModel.editTagList)
            }
        }
        .background(Color.memoBackground)
        .navigationBarBackButtonHidden()
        .onAppear {
            lastSavedContent = viewModel.editContent
        }
        .onChange(of: viewModel.editContent) {
            debounceAutoSave()
        }
        .onDisappear {
            debounceWorkItem?.cancel()
        }
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
        guard viewModel.editContent != lastSavedContent else { return }

        await viewModel.save()
        lastSavedContent = viewModel.editContent
    }
}
