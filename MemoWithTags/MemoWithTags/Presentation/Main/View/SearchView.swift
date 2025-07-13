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
    @InjectedObservable(\.mainViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    @InjectedObservable(\.appState) private var appState
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
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
                        ForEach(viewModel.searchContentTags.toTags(from: appState.tags), id: \.id) { tag in
                            TagView(tag: tag, xmark: true) {
                                viewModel.searchContentTags.removeAll { $0 == tag.id }
                            }
                        }
                        
                        TextField("텍스트와 태그로 메모 검색", text: $viewModel.searchContent)
                            .font(.pretendard(.regular, size: 15))
                            .foregroundStyle(Color.basicText)
                            .onAppear {
                                UITextField.appearance().clearButtonMode = .whileEditing
                            }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.searchBarBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onAppear {
                        Task {
                            await viewModel.search()
                        }
                    }
                    .onChange(of: viewModel.searchContent) {
                        Task {
                            await viewModel.search()
                        }
                    }
                    .onChange(of: viewModel.searchContentTags) {
                        Task {
                            await viewModel.search()
                        }
                    }
                }
                .padding(.leading, 8) // 뒤로가기 버튼의 터치 영역을 넓히기 위해 leading padidng을 줄임
                .padding(.trailing, 16)
                .padding(.bottom, 14)
                
                //MARK: - 로딩 아이콘
                if viewModel.searchLoading {
                    VStack {
                        ProgressView()
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                } else if !viewModel.searchContent.isEmpty && viewModel.searchedMemos.isEmpty && viewModel.searchedTags.isEmpty {
                    VStack {
                        Text("검색결과가 없습니다.")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundStyle(Color.placeholder)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                }
                
                //MARK: - 태그 검색 결과
                if !viewModel.searchLoading && !viewModel.searchedTags.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tags")
                            .font(.pretendard(.medium, size: 12))
                            .foregroundStyle(Color.grayText)
                            .padding(.horizontal, 14)

                        
                        HFlow {
                            ForEach(viewModel.searchedTags.toTags(from: appState.tags), id: \.id) { tag in
                                TagView(tag: tag) {
                                    viewModel.searchContentTags.append(tag.id)
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
                
                //MARK: - 메모 검색 결과
                if !viewModel.searchLoading && !viewModel.searchedMemos.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Memos")
                            .font(.pretendard(.medium, size: 12))
                            .foregroundStyle(Color.grayText)
                            .padding(.horizontal, 26)
                    
                        List {
                            ForEach(viewModel.searchedMemos) { memo in
                                MemoView(memo: memo)
                                    .id(memo.id)
                                    .padding(.vertical, 6)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                                    .padding(.horizontal, 12)
                                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
                            }
                            
                            Color.clear
                                .frame(height: 8)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .onAppear {
                                    Task {
                                        await viewModel.searchMemos(content: viewModel.searchContent, tagIds: viewModel.searchContentTags)
                                    }
                                }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .scrollIndicators(.hidden)
                    }
                }
                
                Spacer()
            }

        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
    }
}

