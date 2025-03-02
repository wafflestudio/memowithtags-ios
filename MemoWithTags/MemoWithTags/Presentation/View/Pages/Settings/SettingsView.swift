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
            Color.backgroundGray
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                HStack {
                    Text("내 계정")
                        .font(.pretendard(.medium, size: 14))
                        .foregroundStyle(Color.titleTextBlack)
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.pretendard(.regular, size: 16))
                        .foregroundStyle(Color.dateGray)
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 17)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .onTapGesture {
                    viewModel.appState.navigation.push(to: .accountSetting)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack{
                        Text("메모 정렬 기준은 만든 날짜 순입니다.")
                            .font(.pretendard(.regular, size: 12))
                            .foregroundStyle(Color.dateGray)
                            .padding(.leading, 6)
                        
                        Spacer()
                    }
                    
                    Text("검색 정렬 기준은 만든 날짜 순입니다.")
                        .font(.pretendard(.regular, size: 12))
                        .foregroundStyle(Color.dateGray)
                        .padding(.leading, 6)
                    
                    
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 17)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            }
            .padding(.horizontal, 12)
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .regular))
                    .onTapGesture {
                        viewModel.appState.navigation.pop()
                    }
            }
            
            ToolbarItem(placement: .navigation) {
                Text("설정")
                    .font(.pretendard(.semibold, size: 18))
                    .foregroundStyle(Color.titleTextBlack)
            }
        }
    }
    
    
    @ViewBuilder private func CustomCell(icon: String, text: String, color: Color? = Color.titleTextBlack, onTap: (() -> Void)?) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.black.opacity(0.5))
            
            Text(text)
                .font(.pretendard(.regular, size: 14))
                .foregroundColor(color)
            
            Spacer()
            
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 18)
        .background(Color.memoBackgroundWhite)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
        .onTapGesture {
            onTap?()
        }
    }
}
