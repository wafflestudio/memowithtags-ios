//
//  InputField.swift
//  MemoWithTags
//
//  Created by 최진모 on 3/13/25.
//

import SwiftUI

struct InputFieldView: View {
    @Binding var text: String
    let placeholder: String
    let showCount: Bool
    let showAlert: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            TextField (
                "",
                text: $text,
                prompt: Text(placeholder)
                    .font(.pretendard(.regular, size: 16))
                    .foregroundStyle(Color.placeholder)
            )
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .font(.pretendard(.regular, size: 16))
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(showAlert ? Color.redText : Color.basicBorder, lineWidth: 1)
            )
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            
            //조건 표시
            HStack {
                if showAlert {
                    Text("16자 이내로 작성해주세요.")
                        .font(.pretendard(.regular, size: 12))
                        .foregroundStyle(Color.redText)
                        .padding(.horizontal, 6)
                }
                
                Spacer()
                
                if showCount {
                    Text("\(text.count)/16")
                        .font(.pretendard(.regular, size: 12))
                        .foregroundStyle(text.count > 16 ? Color.redText: Color.grayText)
                        .padding(.horizontal, 6)
                }
            }
        }
    }
}
