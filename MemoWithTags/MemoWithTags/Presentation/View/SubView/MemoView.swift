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
    @State private var isMenuVisible = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            //MARK: - 메모 내용
            Text(memo.content)
                .font(.pretendard(.regular, size: 14))
                .foregroundColor(Color.basicText)
                .lineLimit(isExpanded ? nil : 2)
                .blur(radius: memo.locked && !viewModel.appState.user.isBioAuthenticated ? 6 : 0)
                .animation(.spring, value: isExpanded)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            if !memo.tagIds.isEmpty || memo.locked {
                HFlow {
                    ForEach(viewModel.getTags(from: memo.tagIds), id: \.id) { tag in
                        TagView(viewModel: viewModel, tag: tag) {
                            onTappingMemo() // MemoView에 있는 Tag는 Tap해도 아무 일이 일어나지 않으므로, Tag를 Tap해도 Memo를 Tap한 것과 같은 일이 일어나게 한다.
                        }
                    }
                    
                    if memo.locked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color.grayText)
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
                        .font(.pretendard(.medium, size: 11))
                        .foregroundStyle(Color.grayText)
                        .padding(.vertical, 3)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("관련 검색")
                            .font(.pretendard(.medium, size: 11))
                            .foregroundStyle(Color.basicText)
                        Image(.searchIcon)
                            .resizable()
                            .frame(width: 11.5, height: 11.5)
                            .foregroundStyle(Color.basicText)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.basicBorder, lineWidth: 1))
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
                            .font(.pretendard(.medium, size: 11))
                            .foregroundStyle(Color.basicText)
                        
                        Image(.aiPenIcon)
                            .resizable()
                            .frame(width: 12, height: 11)
                            .foregroundStyle(Color.basicText)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.basicBorder, lineWidth: 1))
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
                        .foregroundStyle(Color.soft)
                        .frame(width: 27, height: 27)
                        .background(Color.background)
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
        .padding(.vertical, 12)
        .padding(.horizontal, 17)
        .background(Color.memoBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
        .onTapGesture {
            onTappingMemo()
        }
        //MARK: - context menu
        .customContextMenu(
            appState: viewModel.appState,
            type: .memo(memo: memo, tags: viewModel.getTags(from: memo.tagIds)),
            menuItems: [
                .init(title: viewModel.appState.navigation.current == .main ? "이 메모 내용으로 검색하기" : "이 메모를 메인 화면에서 보기",
                      icon: viewModel.appState.navigation.current == .main ? "rectangle.and.text.magnifyingglass" : "text.viewfinder") {
                          Task {
                              if viewModel.appState.navigation.current == .main {
                                  viewModel.clearSearch()
                                  viewModel.searchBarText = memo.content
                                  viewModel.appState.navigation.push(to: .search)
                              } else {
                                  viewModel.appState.navigation.pop()
                                  viewModel.scrollTarget = memo.id
                              }
                          }
                },
                .init(title: memo.locked ? "잠금 해제" : "메모 잠금", icon: memo.locked ? "lock.open.fill" : "lock.fill") {
                    Task {
                        let authenticated = await BioAuthenticationManager.shared.authenticateUser(reason: "메모를 잠그거나 잠금 해제하려면 인증이 필요합니다.")
                        if authenticated {
                            await viewModel.updateMemo(memoId: memo.id, content: memo.content, tagIds: memo.tagIds, locked: !memo.locked)
                        }
                    }
                },
                .init(title: "메모 삭제", icon: "trash", type: .delete) {
                    Task {
                        await viewModel.deleteMemo(memoId: memo.id)
                    }
                }
            ]
        )
        .padding(.horizontal, 12)
    }
    
    //MARK: - 메모 터치했을 때 동작 (메모 잠금해제, 메모 펼치기, 메모 완전 확장)
    func onTappingMemo() {
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
            viewModel.appState.navigation.push(to: .memoEditor)
        }
    }
    
    func dateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
}
