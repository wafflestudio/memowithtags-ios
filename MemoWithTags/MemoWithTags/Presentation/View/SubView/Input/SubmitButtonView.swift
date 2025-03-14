//
//  SubmitButton.swift
//  MemoWithTags
//
//  Created by 최진모 on 3/13/25.
//
import SwiftUI

struct SubmitButtonView: View {
    let text: String
    let loading: Bool
    let disabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            //action
            action()
        } label: {
            Group {
                if loading {
                    ProgressView()
                } else {
                    Text(text)
                }
            }
            .font(.pretendard(.semibold, size: 16))
            .foregroundStyle(disabled ? Color.disabledButtonText : .white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
        .background(disabled || loading ? Color.disabledButtonBackground : Color.buttonBackground)
        .cornerRadius(22)
        .disabled(disabled || loading)
    }
}
