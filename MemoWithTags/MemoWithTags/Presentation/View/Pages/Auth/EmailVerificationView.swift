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
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text(viewModel.appState.navigation.current == .emailEnter ? "이메일로 회원가입" : "비밀번호 찾기")
                        .font(.pretendard(.semibold, size: 21))
                        .foregroundStyle(Color.basicText)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                VStack(spacing: 0) {
                    Text(
                        viewModel.notMatchCode ? "입력하신 인증번호가 올바르지 않습니다." : "이메일로 발송된 인증번호를 입력해주세요."
                    )
                    .padding(.vertical, 8)
                    .font(.pretendard(.regular, size: 16))
                    .foregroundStyle(Color.basicText)
                    
                    //MARK: - 인증 코드 입력란
                    SeparatedTextField(length: 6, value: $code, showAlert: viewModel.notMatchCode)
                        .padding(.top, 8)
                    
                    //MARK: - 확인 버튼
                    SubmitButtonView(text: "다음", loading: viewModel.isLoading, disabled: code.count < 6) {
                        Task {
                            await viewModel.verify(email: email, code: code)
                        }
                    }
                    .padding(.top, 16)
                    
                    //MARK: - 타이머와 재전송 버튼
                    TimerView(viewModel: viewModel, email: email)
                        .padding(.top, 16)
                    
                    //MARK: - 아래 버튼들
                    HStack(spacing: 8) {
                        DesignTagView(text: "이전", fontSize: 13, backGroundColor: .colorlessTag) {
                            viewModel.appState.navigation.pop()
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.TagColor.Red2.color)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.TagColor.Red2.color)
                            .frame(width: 12, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.colorlessTag)
                            .frame(width: 12, height: 24)
                        
                    }
                    .padding(.top, 36)
                }
                .padding(.top, 18)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(Color.memoBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 12)
            .background(.clear)
            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)

        }
        .navigationBarBackButtonHidden()
        
    }
}

//MARK: - 숫자 하나 입력 필드
struct CharacterField: View {
    @Binding var character: String
    var showAlert: Bool
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
                    .stroke(showAlert ? Color.redText : Color.basicBorder, lineWidth: 1)
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
    var showAlert: Bool
    
    @FocusState private var focusedIndex: Int?
    @State private var characters: [String]
    
    init(length: Int, value: Binding<String>, showAlert: Bool) {
        self.length = length
        self._value = value
        self._characters = State(initialValue: Array(repeating: "", count: length))
        self.showAlert = showAlert
    }
    
    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<length, id: \.self) { index in
                CharacterField(character: $characters[index], showAlert: showAlert) { newValue in
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

struct TimerView: View {
    @ObservedObject var viewModel: EmailVerificationViewModel
    let email: String
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            DesignTagView(text: "인증번호 재발송", fontSize: 13, backGroundColor: viewModel.isLoading ? .colorlessTag : .TagColor.Red2.color) {
                Task {
                    await viewModel.sendCode(email: email)
                }
            }

            Spacer()
            
            Text(timeString(time: viewModel.time))
                .font(.pretendard(.regular, size: 14))
                .foregroundStyle(Color.grayText)
            
        }
        .onReceive(timer) { _ in
            if viewModel.time > 0 {
                viewModel.time -= 1
            }
        }
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
