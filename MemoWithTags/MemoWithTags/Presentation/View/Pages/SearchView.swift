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
                                    
                                    viewModel.searchMemosAndTags()
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
                            ForEach(viewModel.searchedTags.filter { tag in
                                !viewModel.searchBarSelectedTags.contains(where: { $0.id == tag.id })
                            }, id: \.id) { tag in
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
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.searchedMemos, id: \.id) { memo in
                                    MemoView(memo: memo, viewModel: viewModel)
                                        .shadow(color: Color.black.opacity(0.05), radius: 6)
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
        .onAppear {
            viewModel.searchMemosAndTags()
        }
        .onDisappear {
            viewModel.clearSearch()
        }
    }
    
    private func removeTagFromSelectedTags(_ tag: Tag) {
        viewModel.searchBarSelectedTags.removeAll { $0.id == tag.id }
        viewModel.searchMemosAndTags()
    }
    
    private func appendTagToSelectedTags(_ tag: Tag) {
        viewModel.searchBarSelectedTags.append(tag)
        viewModel.searchMemosAndTags()
    }
}
