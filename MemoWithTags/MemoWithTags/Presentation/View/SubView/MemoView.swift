//
//  MemoView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI
import Flow
import RichTextKit

@available(iOS 18.0, *)
struct MemoView: View {
    let memo: Memo
    let lineLimit: Int = 2
    
    @ObservedObject var viewModel: MainViewModel
    @State private var isExpanded: Bool = false
    @State private var currentlyLocked = false
    
    @Namespace var namespace
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(memo.content)
                .foregroundColor(Color.memoTextBlack)
                .lineLimit(isExpanded ? nil : lineLimit)
                .blur(radius: currentlyLocked ? 6 : 0)
                .animation(.spring, value: isExpanded)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            if !memo.tags.isEmpty {
                HFlow {
                    ForEach(memo.tags, id: \.id) { tag in
                        TagView(viewModel: viewModel, tag: tag)
                    }
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 한번 클릭 했을 때 나오는 밑에 버튼들
            if isExpanded {
                HStack(alignment: .bottom) {
                    Text(dateFormat(date: memo.createdAt))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.dateGray)
                        .padding(.vertical, 3)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("관련 메모 검색")
                            .font(.system(size: 11, weight: .medium))
                        
                            .foregroundStyle(Color.titleTextBlack)
                        Image(.searchIcon)
                            .resizable()
                            .frame(width: 11.5, height: 11.5)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(.black.opacity(0.15), lineWidth: 1))
                    .onTapGesture {
                        viewModel.clearSearch()
                        viewModel.searchBarText = memo.content
                        // 현재 뷰가 search가 아닌 경우에만 searchPage로 이동
                        if viewModel.appState.navigation.current != .search {
                            viewModel.appState.navigation.push(to: .search)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text("검색하며 수정")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.titleTextBlack)
                        
                        Image(.aiPenIcon)
                            .resizable()
                            .frame(width: 12, height: 11)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(.black.opacity(0.15), lineWidth: 1))
                    .onTapGesture {
                        viewModel.editorState = .update(target: memo)
                        viewModel.editorContent = memo.content
                        viewModel.editorTags = memo.tags
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding(.top, 9)
        .padding(.bottom, 12)
        .padding(.horizontal, 17)
        .background(Color.memoBackgroundWhite)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .matchedTransitionSource(id: "editor\(memo.id)", in: namespace)
        .onAppear {
            currentlyLocked = memo.locked
        }
        .onChange(of: memo.locked) {
            currentlyLocked = memo.locked
        }
        .onTapGesture {
            if currentlyLocked {
                Task {
                    let authenticated = await AuthenticationManager.shared.authenticateUser(reason: "잠김 메모를 확인하려면 인증이 필요합니다.")
                    if authenticated {
                        withAnimation(.spring()) {
                            currentlyLocked = false
                        }
                    }
                }
            } else if !isExpanded {
                withAnimation(.spring) {
                    isExpanded.toggle()
                }
            } else {
                viewModel.editorState = .update(target: memo)
                viewModel.editorContent = memo.content
                viewModel.editorTags = memo.tags
                viewModel.appState.navigation.push(to: .memoEditor(namespace: namespace, id: "editor\(memo.id)"))
            }
        }
        .contextMenu {
            Button {
                viewModel.clearSearch()
                viewModel.searchBarText = memo.content
                // 현재 뷰가 search가 아닌 경우에만 searchPage로 이동
                if viewModel.appState.navigation.current != .search {
                    viewModel.appState.navigation.push(to: .search)
                }
            } label: {
                Label("이 메모 내용으로 검색하기", systemImage: "text.magnifyingglass")
            }
            
            Button {
                Task {
                    let authenticated = await AuthenticationManager.shared.authenticateUser(reason: "메모를 잠그거나 잠금 해제하려면 인증이 필요합니다.")
                    if authenticated {
                        await viewModel.updateMemo(memoId: memo.id, content: memo.content, tagIds: memo.tagIds, locked: !memo.locked)
                    }
                }
            } label: {
                if memo.locked {
                    Label("잠금 해제하기", systemImage: "lock.open")
                } else {
                    Label("매모 잠그기", systemImage: "lock")
                }
            }
            
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteMemo(memoId: memo.id)
                }

            } label: {
                Label("삭제하기", systemImage: "trash")
            }
        }
        .padding(.horizontal, 12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    func dateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "ko_KR")

        return dateFormatter.string(from: date)
    }
}
