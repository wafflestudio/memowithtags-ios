//
//  MainView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    @StateObject private var keyboardManager = KeyboardManager()
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                //MARK: - 메모 리스트
                MemoListView(viewModel: viewModel)
                
                //MARK: - 메모 에디터
                EditingMemoView(viewModel: viewModel)
                
                //MARK: - 태그 에디터
                if keyboardManager.currentHeight > 0 {
                    EditingTagListView(viewModel: viewModel)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.initMemo()
            }
        }
        .toolbar {
            //MARK: - 로고
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 3) {
                    Text("Memo with")
                        .font(.pretendard(.semibold, size: 17))
                        .foregroundStyle(Color.basicText)
                    
                    DesignTagView(text: "Tags", fontSize: 14, backGroundColor: .titleTag) {}
                }
            }
            
            //MARK: - 서치, 설정 창 버튼
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 14) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.basicText)
                        .onTapGesture {
                            viewModel.appState.navigation.push(to: .search)
                        }
                    
                    Image(systemName: "list.bullet")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.basicText)
                        .onTapGesture {
                            viewModel.appState.navigation.push(to: .settings)
                        }
                }
            }

        }
        .navigationBarBackButtonHidden(true)
    }
}

