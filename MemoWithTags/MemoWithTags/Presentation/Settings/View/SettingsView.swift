//
//  SettingsView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI
import Factory

struct SettingsView: View {
    @InjectedObservable(\.navigationState) private var navigation

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
                        Text("태그 관리")
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
                        navigation.push(to: .tagSetting)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("글씨 크기")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                                .padding(.horizontal, 6)
                            
                            HStack {
                                Text("작게")
                                    .font(.pretendard(.regular, size: 15))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                            }
                            .onTapGesture {
                            }
                            
                            HStack {
                                Text("적당히")
                                    .font(.pretendard(.regular, size: 15))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                            }
                            .onTapGesture {
                            }
                            
                            HStack {
                                Text("크게")
                                    .font(.pretendard(.regular, size: 15))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                            }
                            .onTapGesture {
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("메모 정렬 기준")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                                .padding(.horizontal, 6)
                            
                            HStack {
                                Text("만든 날짜")
                                    .font(.pretendard(.regular, size: 15))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                            }
                            .onTapGesture {
                            }
                            
                            HStack {
                                Text("수정한 날짜")
                                    .font(.pretendard(.regular, size: 15))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                            }
                            .onTapGesture {
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 12) {
                        Link(destination: URL(string: "https://wafflestudio.github.io/memowithtags-ios/opensource-license.html")!) {
                            Text("오픈소스 라이센스")
                                .font(.pretendard(.regular, size: 14))
                                .underline()
                                .foregroundStyle(Color.soft)
                        }

                        Link(destination: URL(string: "https://wafflestudio.github.io/memowithtags-ios/service-term.html")!) {
                            Text("이용약관")
                                .font(.pretendard(.regular, size: 14))
                                .underline()
                                .foregroundStyle(Color.soft)
                        }

                        Link(destination: URL(string: "https://wafflestudio.github.io/memowithtags-ios/privacy-policy.html")!) {
                            Text("개인정보처리방침")
                                .font(.pretendard(.regular, size: 14))
                                .underline()
                                .foregroundStyle(Color.soft)
                        }

                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 17)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

            }
            .padding(.horizontal, 12)
            
        }
        .navigationBarBackButtonHidden(true)
    }
}
