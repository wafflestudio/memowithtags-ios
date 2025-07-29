//
//  UpdateTagView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/10/25.
//

import SwiftUI
import Factory

struct TagUpdaterView: View {
    let tag: Tag
    
    @InjectedObservable(\.settingViewModel) private var viewModel
    @InjectedObservable(\.appState) private var appState
    @Environment(\.dismiss) var dismiss
    
    @State private var updatedName: String
    @State private var selectedColor: Color.TagColor
    
    @State private var isLoading: Bool  = false
    @State private var canSave: Bool = false
    
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
        VStack(spacing: 20) {
            Text(updatedName.isEmpty ? "태그명" : updatedName)
                .font(.pretendard(.regular, size: 13))
                .foregroundColor(Color.tagText)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(selectedColor.color)
                .cornerRadius(4)
                .lineLimit(1)
                .truncationMode(.tail)
                .scaleEffect(1.3)
            
            
            VStack(alignment: .leading, spacing: 16) {
                Text("태그명")
                    .font(.pretendard(.regular, size: 12))
                    .foregroundStyle(Color.grayText)
                    .padding(.horizontal, 6)
                
                TagEditInputFieldView(
                    text: $updatedName,
                    placeholder: "태그명",
                    currentTag: tag,
                    allTags: appState.sortedTags,
                    canSave: $canSave,
                    onFavoriteToggle: {
                        viewModel.togleFavoriteTag(tagId: tag.id)
                    },
                    isFavorite: appState.favoriteTags.contains(tag.id)
                )
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
                            .overlay(
                                // 선택된 색상에 체크마크 표시
                                Circle()
                                    .stroke(Color.basicText, lineWidth: selectedColor == tagColor ? 2 : 0)
                            )
                            .onTapGesture {
                                selectedColor = tagColor
                            }
                    }
                }
            }
            
            Spacer()
            
            SubmitButtonView(text: "완료", loading: isLoading, disabled: !canSave) {
                Task {
                    isLoading = true
                    let trimmedName = updatedName.trimmingCharacters(in: .whitespacesAndNewlines)
                    await viewModel.updateTag(tagId: tag.id, name: trimmedName, color: selectedColor)
                    isLoading = false
                    dismiss()
                }
            }
            

        }
        .padding(.vertical, 30)
        .padding(.horizontal, 25)
        .background(Color.memoBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        
    }
}
