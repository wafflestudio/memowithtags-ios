//
//  TagSettingView.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/7/25.
//

import SwiftUI
import Factory
import Flow

struct TagSettingView: View {
    @InjectedObservable(\.settingViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    @InjectedObservable(\.appState) private var appState
    
    @State private var isOn: Bool = false
    
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
                    
                    Text("태그 관리")
                        .font(.pretendard(.semibold, size: 18))
                        .foregroundStyle(Color.basicText)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                
                //MARK: -
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("태그 목록 정렬")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                                .padding(.horizontal, 6)
                            
                            HStack {
                                Text("가나다 순")
                                    .font(.pretendard(.regular, size: 15))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                            }
                            .onTapGesture {
                            }
                            
                            HStack {
                                Text("색상 순")
                                    .font(.pretendard(.regular, size: 15))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                            }
                            .onTapGesture {
                            }
                            
                            HStack {
                                Text("최근 생성순")
                                    .font(.pretendard(.regular, size: 15))
                                    .foregroundStyle(Color.basicText)
                                
                                Spacer()
                            }
                            .onTapGesture {
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Toggle(isOn: $isOn) {
                                Text("메모 내 태그에도 적용")
                                    .font(.pretendard(.regular, size: 15))
                                    .foregroundStyle(Color.basicText)
                            }
                            .tint(Color.TagColor.Red.color)
                        }

                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("태그 개별 수정")
                            .font(.pretendard(.regular, size: 12))
                            .foregroundStyle(Color.grayText)
                            .padding(.horizontal, 6)
                        
                        HFlow {
                            ForEach(appState.tags, id: \.id) { tag in
                                EditableTagView(tag: tag) {
                                    navigation.push(to: .tagDetailedSetting(tag: tag))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 12)
            
        }
        .onAppear {
        }
        .navigationBarBackButtonHidden(true)
    }
}

