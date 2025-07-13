//
//  TagSettingView.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/7/25.
//

import SwiftUI
import Factory
import Flow

struct TagDetailedSettingView: View {
    let tag: Tag
    
    @InjectedObservable(\.settingViewModel) private var viewModel
    @InjectedObservable(\.navigationState) private var navigation
    @InjectedObservable(\.appState) private var appState
    
    @State private var updatedName: String
    @State private var selectedColor: Color.TagColor
    
    @State private var isOn: Bool = false
    
    @State private var isAppeared: Bool = false
    @State private var isLoading: Bool  = false

    
    private let tagColors: [Color.TagColor] = [
        .Red, .Yellow, .Green, .Mint, .Blue, .Purple, .Pink,
        .Red2, .Yellow2, .Green2, .Mint2, .Blue2, .Purple2, .Pink2,
        .Red3, .Yellow3, .Green3, .Mint3, .Blue3, .Purple3, .Pink3
    ]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)

    init(tag: Tag) {
        self.tag = tag
        updatedName = tag.name
        selectedColor = tag.color
    }
    
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
                            Task {
                                await viewModel.updateTag(tagId: tag.id, name: updatedName, color: selectedColor)
                                navigation.pop()
                            }
                        }
                    
                    Text("태그 관리")
                        .font(.pretendard(.semibold, size: 18))
                        .foregroundStyle(Color.basicText)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                
                //MARK: -
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Rectangle()
                            .fill(Color(uiColor: .Palette.W3))
                            .frame(width: 300, height: 9)
                            .cornerRadius(4)
                        Rectangle()
                            .fill(Color(uiColor: .Palette.W2_1))
                            .frame(width: 285, height: 9)
                            .cornerRadius(4)
                        Rectangle()
                            .fill(Color(uiColor: .Palette.W2))
                            .frame(width: 230, height: 9)
                            .cornerRadius(4)
                        
                        Text(updatedName)
                            .font(.pretendard(.regular, size: 13))
                            .foregroundColor(Color.tagText)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(selectedColor.color)
                            .cornerRadius(4)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 17)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("태그명")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                                .padding(.horizontal, 6)
                            
                            InputFieldView(text: $updatedName, placeholder: "태그명", showCount: true, showAlert: updatedName.count > 16)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("태그 색상")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                                .padding(.horizontal, 6)
                            
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(tagColors, id: \.self) { tagColor in
                                    Circle()
                                        .fill(
                                            tagColor.color
                                                .shadow(
                                                    .inner(color: Color.white.opacity(0.1), radius: 2, x: -2, y: -2)
                                                )
                                                .shadow(
                                                    .inner(color: Color.black.opacity(0.1), radius: 2, x: 2, y: 2)
                                                )
                                        )
                                        .frame(width: 35, height: 35)
                                        .onTapGesture {
                                            selectedColor = tagColor
                                        }
                                }
                            }
                        }
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

