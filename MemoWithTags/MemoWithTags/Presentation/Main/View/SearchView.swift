//
//  SearchView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI
import Flow
import Factory

struct SearchView: View {
    @InjectedObservable(\.searchViewModel) private var viewModel: SearchViewModel
    @InjectedObservable(\.navigation) private var navigation: Navigation
    
    @State private var searchText: String = ""
    @State private var searchTags: [Tag] = []
    @State private var searchTask: Task<Void, Never>? = nil
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                //MARK: - 맨 위 바
                HStack(spacing: 2) {
                    //MARK: - 뒤로가기 버튼
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 8, height: 18)
                        .foregroundStyle(Color.soft)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .contentShape(Rectangle()) // 터치 영역을 더 넓게 설정
                        .onTapGesture {
                            navigation.pop()
                        }
                    
                    //MARK: - 검색 창
                    HStack {
                        ForEach(searchTags, id: \.id) { tag in
                            TagView(viewModel: viewModel, tag: tag, addXmark: true) {
                                removeTagFromSelectedTags(tag.id)
                            }
                        }
                        
                        TextField("텍스트와 태그로 메모 검색", text: $searchText)
                            .font(.pretendard(.regular, size: 15))
                            .foregroundStyle(Color.basicText)
                            .onChange(of: searchText) {
                                // 실행하고 있는 searchTask를 종료
                                searchTask?.cancel()
                                
                                // 새로운 searchTask 생성
                                searchTask = Task {
                                    // 0.5초 기다리기
                                    try? await Task.sleep(nanoseconds: 500_000_000)
                                    
                                    await viewModel.search()
                                }
                            }
                            .onAppear {
                                UITextField.appearance().clearButtonMode = .whileEditing
                            }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.searchBarBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.leading, 8) // 뒤로가기 버튼의 터치 영역을 넓히기 위해 leading padidng을 줄임
                .padding(.trailing, 16)
                .padding(.bottom, 14)
                
                //MARK: - 로딩 아이콘
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                }
                
                //MARK: - 태그 검색 결과
                if !viewModel.searchedTagIds.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tags")
                            .font(.pretendard(.medium, size: 12))
                            .foregroundStyle(Color.grayText)
                            .padding(.horizontal, 14)

                        
                        HFlow {
                            ForEach(viewModel.getTags(from: viewModel.searchedTagIds), id: \.id) { tag in
                                TagView(viewModel: viewModel, tag: tag) {
                                    appendTagToSelectedTags(tag.id)
                                    viewModel.searchBarText = ""
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
                
                //MARK: - 메모 검색 결과
                if !viewModel.searchedMemos.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Memos")
                            .font(.pretendard(.medium, size: 12))
                            .foregroundStyle(Color.grayText)
                            .padding(.horizontal, 26)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.searchedMemos, id: \.id) { memo in
                                    MemoView(memo: memo, viewModel: viewModel)
                                }
                                
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .opacity(viewModel.isLoading ? 1 : 0)
                                    Spacer()
                                }.onAppear {
                                    Task {
                                        await viewModel.searchMemos(content: viewModel.searchBarText, tagIds: viewModel.searchBarSelectedTagIds)
                                    }
                                }
                            }
                         }
                         .frame(maxWidth: .infinity)
                    }
                }
                
                Spacer()
            }

        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .onAppear {
            Task {
                await viewModel.search()
            }
        }
        .onDisappear {
            // memoEditor가 나타나는 경우를 제외하고 clearSearch() 호출
            if viewModel.appState.navigation.current != .memoEditor {
                viewModel.clearSearch()
            }
        }
    }
    
    private func removeTagFromSelectedTags(_ tagId: Int) {
        viewModel.searchBarSelectedTagIds.removeAll { $0 == tagId }
        Task {
            await viewModel.search()
        }
    }
    
    private func appendTagToSelectedTags(_ tagId: Int) {
        viewModel.searchBarSelectedTagIds.append(tagId)
        Task {
            await viewModel.search()
        }
    }
}

