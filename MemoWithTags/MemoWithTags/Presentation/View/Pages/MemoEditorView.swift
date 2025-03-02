//
//  test.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/24/25.
//
import SwiftUI
import Flow

struct MemoEditorView: View {
    @ObservedObject var viewModel: MainViewModel

    @StateObject var keyboardManager = KeyboardManager()
    
    var body: some View {
        VStack(spacing: 0) {
            //MARK: - 상단 바
            HStack(spacing: 12) {
                // 왼쪽: 뒤로가기 chevron와 "확인" 버튼
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(Color.black)
                    Text("확인")
                        .font(.pretendard(.medium, size: 17))
                        .foregroundColor(.black)
                }
                .onTapGesture {
                    Task {
                        // "확인" 동작: 제출 후 이전 화면으로 이동
                        await viewModel.submit()
                        viewModel.appState.navigation.pop()
                    }
                }
                
                Spacer()
                
                // 오른쪽: "취소" 버튼
                HStack(spacing: 4) {
                    Text("취소")
                        .font(.pretendard(.medium, size: 17))
                        .foregroundColor(.red)
                }
                .onTapGesture {
                    viewModel.editorState = .create
                    viewModel.editorContent = ""
                    viewModel.editorTagIds = []
                    viewModel.appState.navigation.pop()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            //MARK: - 메모 에디터
            TextEditor(text: $viewModel.editorContent)
                .font(.pretendard(.regular, size: 16))
                .overlay(Group { // placeholder
                    if viewModel.editorContent.isEmpty {
                        Text("메모를 작성해보세요.")
                            .font(.pretendard(.regular, size: 16))
                            .foregroundStyle(Color.dividerGray)
                            .offset(x: 5, y: 10)
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
                        .foregroundStyle(Color.dateGray)
                        .padding(.vertical, 3)
                    
                case let .update(target):
                    Text(dateFormat(date: target.createdAt))
                        .font(.pretendard(.medium, size: 13))
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
            
            if keyboardManager.currentHeight > 0 {
                EditingTagListView(viewModel: viewModel)
            }
        }
        .navigationBarBackButtonHidden()
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
