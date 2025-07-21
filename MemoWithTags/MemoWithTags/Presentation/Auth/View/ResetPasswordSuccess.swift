//
//  ResetPasswordSuccess.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/21/25.
//

import SwiftUI
import Factory

struct ResetPasswordSuccessView: View {
    @InjectedObservable(\.navigationState) private var navigation
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("비밀번호 재설정이 완료되었습니다!")
                        .font(.pretendard(.semibold, size: 21))
                        .foregroundStyle(Color.basicText)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //auth panel
                VStack(spacing: 0) {
                    //MARK: - 안내글
                    VStack(spacing: 2) {
                        Text("비밀번호가 성공적으로 변경되었습니다.")
                            .font(.pretendard(.regular, size: 15))
                            .foregroundStyle(Color.basicText)
                            .multilineTextAlignment(.center)
                        Text("새로운 비밀번호로 로그인해주세요.")
                            .font(.pretendard(.regular, size: 15))
                            .foregroundStyle(Color.basicText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    
                    //MARK: - 로그인 버튼
                    Button {
                        //action
                        navigation.switchTo(.splash)
                    } label: {
                        Text("로그인 하기")
                            .frame(maxWidth: .infinity)
                            .font(.pretendard(.semibold, size: 16))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                    }
                    .background(Color.redText)
                    .cornerRadius(22)
                    .padding(.top, 16)
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
