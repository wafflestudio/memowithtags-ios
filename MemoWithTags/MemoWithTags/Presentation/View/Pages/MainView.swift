//
//  MainView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    @StateObject var keyboardManager = KeyboardManager()
    
    var body: some View {
        ZStack {
            Color.backgroundGray
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                //navigation bar
                HStack(spacing: 14) {
                    if !viewModel.aiRecommendation { //기본 네비게이션 바
                        // 로고
                        HStack(spacing: 3) {
                            Text("Memo with")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.titleTextBlack)
                            
                            DesignTagView(text: "Tags", fontSize: 14, fontWeight: .regular, horizontalPadding: 8, verticalPadding: 3, backGroundColor: "#E3E3E7", cornerRadius: 4) {}
                        }
                        
                        Spacer()
                        
                        // 검색 버튼
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .onTapGesture {
                                viewModel.appState.navigation.push(to: .search)
                            }
                        
                        //설정 버튼
                        Image(systemName: "list.bullet")
                            .font(.system(size: 20))
                            .onTapGesture {
                                viewModel.appState.navigation.push(to: .settings)
                            }
                        
                    } else { //ai 추천 중일 때 네비게이션 바
                        Image(systemName: "chevron.left")
                            .font(.system(size: 19, weight: .regular))
                            .foregroundStyle(Color.black)
                            .onTapGesture {
                                viewModel.aiRecommendation = false
                            }
                        
                        Spacer()
                        
                        Text("\(viewModel.scrollTarget)/\(viewModel.recommendingMemos.count)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.black)
                        
                        Image(.searchIcon)
                            .font(.system(size: 20))
                            .foregroundStyle(Color.black)
                            .onTapGesture {
                                viewModel.appState.navigation.push(to: .search)
                            }
                        
                        //설정 버튼
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .regular))
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(Color.black)
                    }

                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                
                
                Divider()
                
                // 메모 리스트
                MemoListView(viewModel: viewModel)
                
                // 메모 생성 or 수정 창
                EditingMemoView(viewModel: viewModel)
                
                if keyboardManager.currentHeight > 0 {
                    EditingTagListView(viewModel: viewModel)
                }

            }

        }
        .onAppear {
            Task {
                await viewModel.initMainViewModel()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
