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
    
    @InjectedObservable(\.mainViewModel) private var viewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var updatedName: String
    @State private var selectedColor: Color.TagColor

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
        VStack(spacing: 20) {
            Text(updatedName)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.pretendard(.regular, size: 15))
                .foregroundColor(Color.tagText)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(selectedColor.color)
                .cornerRadius(12)
                .rotation3DEffect(.degrees(isAppeared ? 0 : -180), axis: (x: 1, y: 0, z: 0))
                .onAppear {
                    withAnimation(.spring(duration: 1, bounce: 0.3)) {
                        isAppeared = true
                    }
                }
            
            
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
            
            Spacer()
            
            SubmitButtonView(text: "완료", loading: isLoading, disabled: !(1...16 ~= updatedName.count)) {
                Task {
                    isLoading = true
                    await viewModel.updateTag(tagId: tag.id, name: updatedName, color: selectedColor)
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
