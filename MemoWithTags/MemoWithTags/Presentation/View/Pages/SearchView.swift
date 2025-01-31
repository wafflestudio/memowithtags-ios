//
//  SearchView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI
import Flow

struct SearchView: View {
    @ObservedObject var viewModel: MainViewModel
    
    // Timer task for debouncing
    @State private var searchTask: Task<Void, Never>? = nil
    
    var body: some View {
        ZStack {
            Color.backgroundGray
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    // 뒤로가기 버튼
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))
                        .onTapGesture {
                            viewModel.appState.navigation.pop()
                        }
                    
                    HStack {
                        ForEach(viewModel.searchBarSelectedTags, id: \.id) { tag in
                            TagView(viewModel: viewModel, tag: tag, addXmark: true) {
                                removeTagFromSelectedTags(tag)
                            }
                        }
                        
                        TextField("텍스트와 태그로 메모 검색", text: $viewModel.searchBarText)
                            .onChange(of: viewModel.searchBarText) {
                                // 실행하고 있는 searchTask를 종료
                                searchTask?.cancel()
                                
                                // 새로운 searchTask 생성
                                searchTask = Task {
                                    // 0.5초 기다리기
                                    try? await Task.sleep(nanoseconds: 500_000_000)
                                    
                                    await firstSearch()
                                }
                            }
                            .onAppear {
                                UITextField.appearance().clearButtonMode = .whileEditing
                            }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .font(.system(size: 15, weight: .regular))
                    .frame(maxWidth: .infinity)
                    .background(Color.searchBarBackgroundGray)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
                
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                }
                
                // 태그 검색 결과
                if !viewModel.searchedTags.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tags")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.dateGray)
                            .padding(.horizontal, 14)

                        
                        HFlow {
                            ForEach(viewModel.searchedTags, id: \.id) { tag in
                                TagView(viewModel: viewModel, tag: tag) {
                                    appendTagToSelectedTags(tag)
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
                
                // 메모 검색 결과
                if !viewModel.searchedMemos.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Memos")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.dateGray)
                            .padding(.horizontal, 26)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.searchedMemos, id: \.id) { memo in
                                    if #available(iOS 18.0, *) {
                                        MemoView(memo: memo, viewModel: viewModel)
                                    } else {
                                        // 애니메이션이 일단 ios18만 지원되는 상태..
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
        .navigationBarBackButtonHidden()
        .onDisappear {
            viewModel.clearSearch()
        }
    }
    
    private func removeTagFromSelectedTags(_ tag: Tag) {
        viewModel.searchBarSelectedTags.removeAll { $0.id == tag.id }
        Task {
            await firstSearch()
        }
    }
    
    private func appendTagToSelectedTags(_ tag: Tag) {
        viewModel.searchBarSelectedTags.append(tag)
        Task {
            await firstSearch()
        }
    }
    
    private func firstSearch() async {
//        // 이전 검색 결과를 모두 리셋
//        viewModel.searchedMemos = []
//        viewModel.searchedTags = []
//        viewModel.searchCurrentPage = 0
//        viewModel.searchTotalPages = 1
//        
//        let trimmedText = viewModel.searchBarText.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        // 검색할 text와 tag가 있는지 확인
//        if !trimmedText.isEmpty || !viewModel.searchBarSelectedTags.isEmpty {
//            // 선택한 tag들의 id를 뽑아서 tagId list로 만듦
//            let selectedTagIds = viewModel.searchBarSelectedTags.map { $0.id }
//            
//            // Perform the search with content and selected tag IDs
//            await viewModel.searchMemos(content: trimmedText, tagIds: selectedTagIds)
//            
//            // 검색창의 text에 맞는 tag를 local에서 찾아서 반환
//            viewModel.searchedTags = viewModel.tags.filter { tag in
//                tag.name.lowercased().contains(trimmedText.lowercased()) && !selectedTagIds.contains(tag.id)
//            }
//        }
    }
    
    private func fetchNextPage() async {
//        let trimmedText = viewModel.searchBarText.trimmingCharacters(in: .whitespacesAndNewlines)
//        let selectedTagIds = viewModel.searchBarSelectedTags.map { $0.id }
//        await viewModel.searchMemos(content: trimmedText, tagIds: selectedTagIds)
    }
}
