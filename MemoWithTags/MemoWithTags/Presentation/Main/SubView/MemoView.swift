//
//  MemoView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI
import Flow
import Factory

struct MemoView: View {
    let memo: Memo
    
    @InjectedObservable(\.mainViewModel) private var viewModel
    @InjectedObservable(\.appState) private var appState
    @InjectedObservable(\.navigationState) private var navigation
    
    let maxHeight: CGFloat = 100

    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            //MARK: - 메모 내용
            Text(memo.content)
                .font(.pretendard(.regular, size: 14))
                .foregroundColor(Color.basicText)
                .lineSpacing(3)
                .blur(radius: memo.locked && !appState.isBioAuthenticated ? 6 : 0)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .mask(
                    VStack(spacing: 0) {
                        // 위쪽은 그대로 보이고
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: isExpanded ? nil : maxHeight - 30)
                        
                        // 아래쪽은 점점 사라짐
                        if !isExpanded {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black, .clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 30)
                        }
                    }
                )
                .frame(maxHeight: isExpanded ? nil : maxHeight)
            
            //MARK: - 태그
            if !memo.tagIds.isEmpty {
                HFlow {
                    ForEach(memo.tagIds.toTags(from: viewModel.tags), id: \.id) { tag in
                        TagView(tag: tag) {
                            onTappingMemo()
                        }
                    }
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            //MARK: - 메모 펼쳤을 때 나오는 밑에 버튼들
            if isExpanded {
                HStack(alignment: .bottom) {
                    if memo.locked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color.grayText)
                            .font(.system(size: 14))
                    }
                    
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
                        viewModel.editContent = memo.content
                        viewModel.editTagList = memo.tagIds
                        viewModel.editState = .updating(memo: memo)
                    }
                    
                    // 접기 버튼
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.soft)
                        .frame(width: 27, height: 27)
                        .background(Color.background)
                        .clipShape(Circle())
                        .onTapGesture {
                            isExpanded = false
                        }
                }
                .padding(.top, 10)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 17)
        .background(Color.memoBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .redacted(reason: memo.state == .creating ? .placeholder : [])
        .matchedTransitionSource(id: memo.id, in: navigation.namespace)
        .onTapGesture {
            onTappingMemo()
        }
        .customContextMenu(
            preview: .memo(memo: memo),
            [
                .init(icon: navigation.current == .main ? "document.on.document.fill" : "text.viewfinder",
                      title: navigation.current == .main ? "메모 내용 복사" : "이 메모를 메인 화면에서 보기") {
                    Task {
                      if navigation.current == .main {
                          UIPasteboard.general.string = memo.content
                      } else {
                          navigation.pop()
//                          viewModel.scrollTarget = memo.id
                      }
                    }
                },
                .init(icon: memo.locked ? "lock.open.fill" : "lock.fill", title: memo.locked ? "잠금 해제" : "메모 잠금") {
                    Task {
                        if appState.isBioAuthenticated {
                            await viewModel.updateMemo(memoId: memo.id, content: memo.content, tagIds: memo.tagIds, locked: !memo.locked)
                        } else {
                            let authenticated = await BioAuthenticationManager.shared.authenticateUser(reason: "메모를 잠그거나 잠금 해제하려면 인증이 필요합니다.")
                            if authenticated {
                                await viewModel.updateMemo(memoId: memo.id, content: memo.content, tagIds: memo.tagIds, locked: !memo.locked)
                                withAnimation(.spring) {
                                    appState.isBioAuthenticated = true
                                }
                            }
                        }
                    }
                },
                .init(icon: "trash", title: "메모 삭제", type: .delete) {
                    Task {
                        await viewModel.deleteMemo(memoId: memo.id)
                    }
                }
            ]
        )
    }
    
    //MARK: - 메모 터치했을 때 동작 (메모 잠금해제, 메모 펼치기, 메모 완전 확장)
    func onTappingMemo() {
        if memo.locked && !appState.isBioAuthenticated {
            Task {
                let authenticated = await BioAuthenticationManager.shared.authenticateUser(reason: "잠긴 메모를 확인하려면 인증이 필요합니다.")
                if authenticated {
                    // 이렇게 API 통신이 있어야 authenticated됐을 때 블러가 바로 없어진다.
                    await viewModel.updateMemo(memoId: memo.id, content: memo.content, tagIds: memo.tagIds, locked: memo.locked)
                    withAnimation(.default) {
                        appState.isBioAuthenticated = true
                    }
                }
            }
        } else if !isExpanded {
            isExpanded = true
        } else {
//            viewModel.editContent = memo.content
//            viewModel.editTagList = memo.tagIds
//            viewModel.editState = .updating(memo: memo)
            navigation.push(to: .fullEditor(id: memo.id))
        }
    }
    
    func dateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
}
