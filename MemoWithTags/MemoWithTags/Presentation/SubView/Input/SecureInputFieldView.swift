//
//  SecureField.swift
//  MemoWithTags
//
//  Created by 최진모 on 3/13/25.
//

import SwiftUI

struct SecureInputFieldView: View {
    @Binding var password: String
    
    let placeholder: String
    let showCondition: Bool
    
    @State private var isValidLength: Bool = false
    @State private var isValidPasswordFormat: Bool = false
    
    func checkPasswordValidity(password: String) {
        let containsUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let containsLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let containsNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let containsSpecialCharacter = password.range(of: "[!@#$%^&*?_+=-]", options: .regularExpression) != nil
        
        isValidLength = password.count >= 8 && password.count <= 16
        isValidPasswordFormat = containsUppercase && containsLowercase && containsNumber && containsSpecialCharacter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SecureField(
                "",
                text: $password,
                prompt: Text(placeholder)
                    .font(.pretendard(.regular, size: 16))
                    .foregroundStyle(Color.placeholder)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .font(.pretendard(.regular, size: 16))
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.basicBorder, lineWidth: 1)
            )
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .onChange(of: password) { _, newPassword in
                checkPasswordValidity(password: newPassword)
            }
            
            //조건 표시
            if showCondition {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.pretendard(.regular, size: 12))
                            .foregroundStyle(isValidLength ? Color.basicText : Color.grayText)
                        Text("최소 8자 ~ 최대 16자")
                            .font(.pretendard(.regular, size: 12))
                            .foregroundStyle(isValidLength ? Color.basicText : Color.grayText)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.pretendard(.regular, size: 12))
                            .foregroundStyle(isValidPasswordFormat ? Color.basicText : Color.grayText)
                        Text("알파벳 대소문자, 숫자, 특수문자 포함")
                            .font(.pretendard(.regular, size: 12))
                            .foregroundStyle(isValidPasswordFormat ? Color.basicText : Color.grayText)
                    }
                }
                .padding(.horizontal, 6)
            }
           
        }
    }
}
