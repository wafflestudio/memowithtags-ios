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
            .padding(.horizontal, 12)
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.soft)
                    .onTapGesture {
                        viewModel.appState.navigation.pop()
                    }
            }
            
            ToolbarItem(placement: .navigation) {
                Text("설정")
                    .font(.pretendard(.semibold, size: 18))
                    .foregroundStyle(Color.basicText)
            }
        }
    }
}
