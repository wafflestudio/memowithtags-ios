//
//  SettingsView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI
import Factory

struct SettingsView: View {
    @InjectedObservable(\.navigation) private var navigation: Navigation
    
    @State private var showingOpenSourceLicense = false
    @State private var showingServiceTerm = false
    @State private var showingPrivacyPolicy = false
    
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
                            navigation.pop()
                        }
                    
                    Text("설정")
                        .font(.pretendard(.semibold, size: 18))
                        .foregroundStyle(Color.basicText)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                
                //MARK: - 아래 메뉴들
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
                        navigation.push(to: .accountSetting)
                    }

                    HStack {
                        Text("오픈소스 라이센스")
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
                        showingOpenSourceLicense = true
                    }

                    HStack {
                        Text("이용약관")
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
                        showingServiceTerm = true
                    }

                    HStack {
                        Text("개인정보처리방침")
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
                        showingPrivacyPolicy = true
                    }
                }

            }
            .padding(.horizontal, 12)
            
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingOpenSourceLicense) {
            DocumentView(
                title: "오픈소스 라이센스",
                content: Documents.openSourceLicense
            )
        }
        .sheet(isPresented: $showingServiceTerm) {
            DocumentView(
                title: "이용약관",
                content: Documents.serviceTerm
            )
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            DocumentView(
                title: "개인정보처리방침",
                content: Documents.privacyPolicy
            )
        }
    }
}
