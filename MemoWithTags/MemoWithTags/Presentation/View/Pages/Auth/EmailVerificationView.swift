//
//  EmailVerificationView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/6/25.
//

import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: EmailVerificationViewModel
    
    let email: String
    
    @State private var code: String = ""
    
    var body: some View {
        
        ZStack {
            Color.W2_1.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text(viewModel.appState.navigation.current == .emailEnter ? "이메일로 회원가입" : "비밀번호 찾기")
                        .font(.pretendard(.semibold, size: 21))
                        .foregroundStyle(Color.B2)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                VStack(spacing: 0) {
                    Text("이메일로 발송된 인증번호를 입력해주세요.")
                        .padding(.vertical, 8)
                        .font(.pretendard(.regular, size: 16))
                        .foregroundStyle(Color.B2)
                    
                    //MARK: - 인증 코드 입력란
                    SeparatedTextField(length: 6, value: $code)
                        .padding(.top, 8)
                    
                    //MARK: - 확인 버튼
                    Button {
                        //action
                        Task {
                            await viewModel.verify(email: email, code: code)
                        }
                        
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("다음")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .font(.pretendard(.semibold, size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                    }
                    .background(code.count < 6 || viewModel.isLoading ? Color(hex: "#E3E3E7") : Color.B2)
                    .cornerRadius(22)
                    .padding(.top, 16)
                    .disabled(code.count < 6 || viewModel.isLoading)
                    
                    //MARK: - 아래 버튼들
                    HStack(spacing: 8) {
                        DesignTagView(text: "이전", fontSize: 13, fontWeight: .regular, horizontalPadding: 6, verticalPadding: 2, backGroundColor: "#E3E3E7", cornerRadius: 4) {
                            viewModel.appState.navigation.pop()
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.TextRed)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.TextRed)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F1F1F3"))
                            .frame(width: 12, height: 24)
                        
                    }
                    .padding(.top, 36)
                }
                .padding(.top, 18)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 12)
            .background(.clear)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)

        }
        .navigationBarBackButtonHidden()
        
    }
}

//MARK: - 숫자 하나 입력 필드
struct CharacterField: View {
    @Binding var character: String
    @FocusState var isFocused: Bool

    var onChange: (_ newValue: String) -> Void

    var body: some View {
        TextField("", text: $character)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .frame(width: 36, height: 52)
            .font(.system(size: 22, weight: .semibold))
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "#181E2226"), lineWidth: 1)
            )
            .onChange(of: character) { oldValue, newValue in
                if newValue.count > 1 {
                    character = String(newValue.prefix(1)) // 첫 글자만 유지
                }
                onChange(character)
            }
            .focused($isFocused)
    }
}

//MARK: - 인증코드 입력 필드
struct SeparatedTextField: View {
    var length: Int
    @Binding var value: String
    
    @FocusState private var focusedIndex: Int?
    @State private var characters: [String]
    
    init(length: Int, value: Binding<String>) {
        self.length = length
        self._value = value
        self._characters = State(initialValue: Array(repeating: "", count: length))
    }
    
    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<length, id: \.self) { index in
                CharacterField(character: $characters[index]) { newValue in
                    handleInputChange(for: index, with: newValue)
                }
                .font(.pretendard(.semibold, size: 22))
                .focused($focusedIndex, equals: index)
            }
        }
        .onAppear {
            focusedIndex = 0 // 첫 번째 필드에 포커스
        }
    }
    
    /// 입력값 변경 처리
    private func handleInputChange(for index: Int, with newValue: String) {
        characters[index] = newValue
        value = characters.joined() // 전체 문자열 업데이트
        
        if !newValue.isEmpty {
            if index < length - 1 {
                focusedIndex = index + 1 // 다음 필드로 포커스 이동
            } else {
                focusedIndex = nil // 마지막 필드에서 포커스 해제
            }
        } else if index > 0 {
            focusedIndex = index - 1 // 이전 필드로 포커스 이동
        }
    }
}
