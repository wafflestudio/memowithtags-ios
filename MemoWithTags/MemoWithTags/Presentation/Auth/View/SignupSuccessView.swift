//
//  SignupSuccessView.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/6/25.
//

import SwiftUI
import Factory

struct SignupSuccessView: View {
    @InjectedObservable(\.navigationState) private var navigation
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 36) {
                //MARK: - title
                HStack(spacing: 4) {
                    Text("회원가입이 완료되었습니다!")
                        .font(.pretendard(.semibold, size: 21))
                        .foregroundStyle(Color.basicText)
                }
                .padding(.vertical, 8)
                .background(.clear)
                
                //auth panel
                VStack(spacing: 0) {
                    //MARK: - 환영글
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            HStack(spacing: 3) {
                                Text("Memo with")
                                    .font(.pretendard(.semibold, size: 17))
                                    .foregroundStyle(Color.basicText)
                                
                                DesignTagView(text: "Tags", fontSize: 14, backGroundColor: Color.titleTag) {}
                            }
                            Text("를 통해")
                                .font(.pretendard(.regular, size: 15))
                                .foregroundStyle(Color.basicText)
                        }
                        Text("복잡한 메모들을 간단하고 효율적으로 정리해보세요!")
                            .font(.pretendard(.regular, size: 15))
                            .foregroundStyle(Color.basicText)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    
                    //MARK: - 시작버튼
                    Button {
                        //action
                        navigation.reset()
                    } label: {
                        Text("시작하기")
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

