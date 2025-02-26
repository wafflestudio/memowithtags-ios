//
//  MemoView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI
import Flow

struct MemoView: View {
    let memo: Memo
    @ObservedObject var viewModel: MainViewModel
    
    @State private var isExpanded: Bool = false
    @Namespace var namespace
    @State private var showFullScreenEditor: Bool = false
  
    @State private var isMenuVisible = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            //MARK: - 메모 내용
            Text(memo.content)
                .foregroundColor(Color.memoTextBlack)
                .lineLimit(isExpanded ? nil : 2)
                .blur(radius: memo.locked && !viewModel.appState.user.isBioAuthenticated ? 6 : 0)
                .animation(.spring, value: isExpanded)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            if !memo.tagIds.isEmpty || memo.locked {
                HFlow {
                    ForEach(viewModel.getTags(from: memo.tagIds), id: \.id) { tag in
                        TagView(viewModel: viewModel, tag: tag)
                    }
                    
                    if memo.locked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color.lockIconGray)
                            .font(.system(size: 14))
                    }
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            //MARK: - 메모 펼쳤을 때 나오는 밑에 버튼들
            if isExpanded {
                HStack(alignment: .bottom) {
                    Text(dateFormat(date: memo.createdAt))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.dateGray)
                        .padding(.vertical, 3)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("관련 검색")
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
                        Text("간편 수정")
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
                        viewModel.editorTagIds = memo.tagIds
                        if viewModel.appState.navigation.current != .main {
                            viewModel.appState.navigation.pop()
                        }
                    }
                    
                    // 접기 버튼
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.memoTextBlack.opacity(0.6))
                        .frame(width: 27, height: 27)
                        .background(Color.backgroundGray)
                        .clipShape(Circle())
                        .onTapGesture {
                            withAnimation(.spring) {
                                isExpanded = false
                            }
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
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        //MARK: - 메모 터치했을 때 동작 (메모 잠금해제, 메모 펼치기, 메모 완전 확장)
        .onTapGesture {
            if memo.locked && !viewModel.appState.user.isBioAuthenticated {
                Task {
                    let authenticated = await BioAuthenticationManager.shared.authenticateUser(reason: "잠김 메모를 확인하려면 인증이 필요합니다.")
                    if authenticated {
                        withAnimation(.spring()) {
                            viewModel.appState.user.isBioAuthenticated = true
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
                viewModel.editorTagIds = memo.tagIds
                showFullScreenEditor = true
            }
        }
        .customContextMenu(isPresented: $isMenuVisible)
        //MARK: - context menu
//        .contextMenu {
//            Button {
//                Task {
//                    let authenticated = await BioAuthenticationManager.shared.authenticateUser(reason: "메모를 잠그거나 잠금 해제하려면 인증이 필요합니다.")
//                    if authenticated {
//                        await viewModel.updateMemo(memoId: memo.id, content: memo.content, tagIds: memo.tagIds, locked: !memo.locked)
//                    }
//                }
//            } label: {
//                if memo.locked {
//                    Label("잠금 해제", systemImage: "lock.open")
//                } else {
//                    Label("메모 잠금", systemImage: "lock")
//                }
//            }
//            // searchView에서만 나타나는 추가 메뉴 항목: 메인 페이지에서 해당 메모 보기
//            if viewModel.appState.navigation.current == .search {
//                Button {
//                    // 메인 페이지로 돌아갑니다.
//                    viewModel.appState.navigation.pop()
//                    // 이 부분을 새로 구현해야 한다.
//                } label: {
//                    Label("이 메모를 메인 화면에서 보기", systemImage: "arrow.left")
//                }
//            }
//            
//            Button(role: .destructive) {
//                Task {
//                    await viewModel.deleteMemo(memoId: memo.id)
//                }
//
//            } label: {
//                Label("메모 삭제", systemImage: "trash")
//            }
//        }
        .padding(.horizontal, 12)
//
    }
    
    func dateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
}
