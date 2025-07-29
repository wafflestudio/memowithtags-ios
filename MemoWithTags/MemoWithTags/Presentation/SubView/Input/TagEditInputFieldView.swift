//
//  TagEditInputFieldView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 7/30/25.
//

import SwiftUI

struct TagEditInputFieldView: View {
    @Binding var text: String
    let placeholder: String
    let currentTag: Tag
    let allTags: [Tag]
    @Binding var canSave: Bool
    let onFavoriteToggle: () -> Void
    let isFavorite: Bool
    
    // 태그명 중복 검사 함수
    private var isDuplicateName: Bool {
        let trimmedName = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 빈 문자열이거나 원래 이름과 같으면 중복이 아님
        if trimmedName.isEmpty || trimmedName == currentTag.name {
            return false
        }
        
        // 다른 태그들 중에 같은 이름이 있는지 확인
        return allTags.contains { existingTag in
            existingTag.id != currentTag.id && existingTag.name == trimmedName
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .font(.pretendard(.regular, size: 16))
                        .foregroundStyle(Color.placeholder)
                )
                .font(.pretendard(.regular, size: 16))
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .onChange(of: text) { _, newValue in
                    // 텍스트 변경 시 저장 가능 여부 업데이트
                    updateCanSave()
                }
                
                // 구분선
                Rectangle()
                    .foregroundColor(Color.placeholder)
                    .frame(width: 0.3, height: 32)
                    .padding(.horizontal, 14)
                
                // 즐겨찾기 별 아이콘
                Button(action: onFavoriteToggle) {
                    Image(isFavorite ? .starFilledIcon : .starIcon)
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                .padding(.trailing, 2)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isDuplicateName ? Color.redText : Color.basicBorder, lineWidth: 1)
            )
            
            // 중복 경고 메시지
            HStack {
                if isDuplicateName {
                    Text("이미 같은 이름의 태그가 존재합니다.")
                        .font(.pretendard(.regular, size: 12))
                        .foregroundStyle(Color.redText)
                        .padding(.horizontal, 6)
                }
                
                Spacer()
            }
        }
        .onAppear {
            updateCanSave()
        }
    }
    
    // 저장 가능 여부 업데이트 함수
    private func updateCanSave() {
        let trimmedName = text.trimmingCharacters(in: .whitespacesAndNewlines)
        canSave = !trimmedName.isEmpty && !isDuplicateName
    }
}