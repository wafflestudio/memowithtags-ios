//
//  MainView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import SwiftUI
import Factory

struct MainView: View {
    @InjectedObservable(\.mainViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    
    @StateObject private var keyboardManager = KeyboardManager()
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 4) {
                MemoListView()
                
                Spacer()
                
                EditorView()
            }
        }
        .onAppear {
            Task {
                await viewModel.initialize()
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
                            navigation.push(to: .search)
                        }
                    
                    Image(systemName: "list.bullet")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.basicText)
                        .onTapGesture {
                            navigation.push(to: .settings)
                        }
                }
            }

        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

