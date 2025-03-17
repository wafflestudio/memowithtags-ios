//
//  SettingsView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //MARK: - navigation bar
                
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19))
                        .foregroundStyle(Color.soft)
                        .padding(12) // 터치 영역을 확장하기 위해 패딩 추가
                        .contentShape(Rectangle()) // 전체 영역을 터치 가능 영역으로 지정
                        .onTapGesture {
                            viewModel.appState.navigation.pop()
                        }
                    
                    Text("설정")
                        .font(.pretendard(.semibold, size: 18))
                        .foregroundStyle(Color.basicText)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                
                //MARK: -
                VStack(spacing: 12) {
                    HStack {
                        Text("내 계정")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundStyle(Color.basicText)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.pretendard(.regular, size: 16))
                            .foregroundStyle(Color.soft)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        viewModel.appState.navigation.push(to: .accountSetting)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack{
                            Text("메모 정렬 기준은 만든 날짜 순입니다.")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                                .padding(.leading, 6)
                            
                            Spacer()
                        }
                        
                        Text("검색 정렬 기준은 만든 날짜 순입니다.")
                            .font(.pretendard(.regular, size: 12))
                            .foregroundStyle(Color.grayText)
                            .padding(.leading, 6)
                        
                        
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

            }
            .padding(.horizontal, 12)
            
        }
        .navigationBarBackButtonHidden(true)
    }
}
