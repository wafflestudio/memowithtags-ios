//
//  SwiftUIView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 5/20/25.
//

import SwiftUI

struct DocumentView: View {
    let title: String
    let content: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Text(title)
                        .font(.pretendard(.semibold, size: 18))
                        .foregroundStyle(Color.basicText)
                    Spacer()
                    Button("닫기", action: { dismiss() })
                        .font(.pretendard(.regular, size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.background) // 네비게이션 바 배경

                // ScrollView for content
                ScrollView {
                    Text(content)
                        .font(.pretendard(.regular, size: 14))
                        .foregroundStyle(Color.basicText)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.memoBackground)
                .padding(.horizontal, 16)
            }
            .background(Color.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}
