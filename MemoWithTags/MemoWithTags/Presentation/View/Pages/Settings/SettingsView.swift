//
//  SettingsView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingOpenSourceLicense = false
    @State private var showingServiceTerm = false
    @State private var showingPrivacyPolicy = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //MARK: - navigation bar
                
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19))
                        .foregroundStyle(Color.soft)
                        .padding(12) // 터치 영역을 확장하기 위해 패딩 추가
                        .contentShape(Rectangle()) // 전체 영역을 터치 가능 영역으로 지정
                        .onTapGesture {
                            viewModel.appState.navigation.pop()
                        }
                    
                    Text("설정")
                        .font(.pretendard(.semibold, size: 18))
                        .foregroundStyle(Color.basicText)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("내 계정")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundStyle(Color.basicText)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.pretendard(.regular, size: 16))
                            .foregroundStyle(Color.soft)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        viewModel.appState.navigation.push(to: .accountSetting)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack{
                            Text("메모 정렬 기준은 만든 날짜 순입니다.")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                                .padding(.leading, 6)
                            
                            Spacer()
                        }
                        
                        Text("검색 정렬 기준은 만든 날짜 순입니다.")
                            .font(.pretendard(.regular, size: 12))
                            .foregroundStyle(Color.grayText)
                            .padding(.leading, 6)
                        
                        
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    HStack {
                        Text("오픈소스 라이센스")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundStyle(Color.basicText)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.pretendard(.regular, size: 16))
                            .foregroundStyle(Color.soft)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        showingOpenSourceLicense = true
                    }

                    HStack {
                        Text("이용약관")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundStyle(Color.basicText)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.pretendard(.regular, size: 16))
                            .foregroundStyle(Color.soft)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        showingServiceTerm = true
                    }

                    HStack {
                        Text("개인정보처리방침")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundStyle(Color.basicText)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.pretendard(.regular, size: 16))
                            .foregroundStyle(Color.soft)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        showingPrivacyPolicy = true
                    }

                    // MARK: - 피드백 안내
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("피드백")
                                .font(.pretendard(.medium, size: 14))
                                .foregroundStyle(Color.basicText)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("버그 신고나 새로운 기능 제안이 있으시면")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                            
                            CopyableText(text: "memowithtags@gmail.com")
                                .font(.pretendard(.medium, size: 12))
                                .foregroundColor(Color.redText)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("으로 연락주세요!")
                                .font(.pretendard(.regular, size: 12))
                                .foregroundStyle(Color.grayText)
                        }
                        .padding(.leading, 6)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                }

            }
            .padding(.horizontal, 12)
            
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingOpenSourceLicense) {
            DocumentView(
                title: "오픈소스 라이센스",
                content: Documents.openSourceLicense
            )
        }
        .sheet(isPresented: $showingServiceTerm) {
            DocumentView(
                title: "이용약관",
                content: Documents.serviceTerm
            )
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            DocumentView(
                title: "개인정보처리방침",
                content: Documents.privacyPolicy
            )
        }
    }
}

// MARK: - CopyableText - 일단은 이렇게 복잡하게 구현했는데, 나중에는 "개발자 괴롭히기" 버튼을 누르면 아예 새로운 창에서 사용자가 피드백을 보낼 수 있게 하자.
struct CopyableText: UIViewRepresentable {
    let text: String
    
    func makeUIView(context: Context) -> UILabel {
        let label = CopyableLabel()
        label.text = text
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
        return uiView.sizeThatFits(CGSize(width: proposal.width ?? .infinity, height: .infinity))
    }
}

class CopyableLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }
    
    private func setupLabel() {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        becomeFirstResponder()
        
        let menuController = UIMenuController.shared
        if !menuController.isMenuVisible {
            menuController.showMenu(from: self, rect: bounds)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.hideMenu()
    }
}
