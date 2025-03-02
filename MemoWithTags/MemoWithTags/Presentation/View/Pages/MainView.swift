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
            Color.backgroundGray
                .ignoresSafeArea()
            
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
                        .foregroundStyle(Color.titleTextBlack)
                    
                    DesignTagView(text: "Tags", fontSize: 14, fontWeight: .regular, horizontalPadding: 5, verticalPadding: 1, backGroundColor: "#E3E3E7", cornerRadius: 4) {}
                }
            }
            
            //MARK: - 서치, 설정 창 버튼
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 14) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                        .onTapGesture {
                            viewModel.appState.navigation.push(to: .search)
                        }
                    Image(systemName: "list.bullet")
                        .font(.system(size: 15))
                        .onTapGesture {
                            viewModel.appState.navigation.push(to: .settings)
                        }
                }
            }

        }
        .navigationBarBackButtonHidden(true)
    }
}

