//
//  contextMenu.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/25/25.
//

import SwiftUI
import Flow

//MARK: - view modifier 설정
extension View {
    func customContextMenu(
        appState: AppState,
        type: PreviewType,
        menuItems: [MenuStruct]
    ) -> some View {
        self.modifier(
            CustomContextMenu(
                appState: appState,
                type: type,
                menuItems: menuItems
            )
        )
    }
}

struct CustomContextMenu: ViewModifier {
    @State private var position: CGRect?
    @State private var pressLocation: CGPoint? // 터치 위치 저장
    @State private var isPressing: Bool = false
    
    let appState: AppState
    let type: PreviewType
    let menuItems: [MenuStruct]
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressing ? 1.03 : 1)
            .shadow(color: Color.black.opacity(isPressing ? 0.3 : 0.05), radius: 6, x: 0, y: 2)
            .onLongPressGesture {
                guard let position = position, let pressLocation = pressLocation else { return }
                if position.minY < 50 || position.maxY > UIScreen.main.bounds.height - 50 {
                    let newPosition = CGPoint(
                        x: position.midX,
                        y: position.minY + pressLocation.y
                    )
                    appState.system.presentContextMenu(at: newPosition, type: type, menuItmes: menuItems)
                } else {
                    appState.system.presentContextMenu(at: CGPoint(x: position.midX, y: position.midY), type: type, menuItmes: menuItems)
                }

            } onPressingChanged: { isPressing in
                if isPressing {
                    switch type {
                    case .memo(let memo, _):
                        if memo.locked && !appState.user.isBioAuthenticated {
                            Task {
                                let authenticated = await BioAuthenticationManager.shared.authenticateUser(reason: "잠김 메모를 확인하려면 인증이 필요합니다.")
                                if authenticated {
                                    appState.user.isBioAuthenticated = true
                                }
                            }
                            return
                        }
                    default: break
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.isPressing = isPressing
                    }
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        pressLocation = value.location // 터치 시작 위치 저장
                    }
            )
            .readPosition { newPosition in
                position = newPosition
            }
    }
}

//MARK: - 위치 추적
extension View {
    func readPosition(onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: PositionPreferenceKey.self,
                        value: proxy.frame(in: .global)
                    )
            }
        )
        .onPreferenceChange(PositionPreferenceKey.self, perform: onChange)
    }
}

struct PositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

//MARK: - 배경 블러
struct BackdropView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect()
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = blur }
        animator.fractionComplete = 0
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}

struct BackdropBlurView: View {
    let radius: CGFloat

    @ViewBuilder
    var body: some View {
        BackdropView().blur(radius: radius)
    }
}

//MARK: - 프리뷰
enum PreviewType {
    case memo(memo: Memo, tags: [Tag])
    case tag(tag: Tag)
}

struct Preview: View {
    let type: PreviewType
    
    var body: some View {
        switch type {
        case .memo(let memo, let tags):
            MemoPreview(memo: memo, tags: tags)
        case .tag(let tag):
            TagPreview(tag: tag)
        }
        
    }
}

struct MemoPreview: View {
    let memo: Memo
    let tags: [Tag]
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(memo.content)
                .font(.pretendard(.regular, size: 14))
                .foregroundColor(Color.memoTextBlack)
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            if !tags.isEmpty {
                HFlow {
                    ForEach(tags, id: \.id) { tag in
                        Text(tag.name)
                            .font(.pretendard(.regular, size: 13))
                            .foregroundColor(Color.tagTextColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tag.color.color)
                            .cornerRadius(4)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if memo.locked {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color.lockIconGray)
                        .font(.system(size: 14))
                    Spacer()
                }
                .padding(.vertical, 7)
            }
            
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 18)
        .background(Color.memoBackgroundWhite)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 0)
        .padding(.horizontal, 8)
    }
}

struct TagPreview: View {
    let tag: Tag
    
    var body: some View {
        Text(tag.name)
            .font(.pretendard(.regular, size: 15))
            .foregroundColor(Color.tagTextColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(tag.color.color)
            .cornerRadius(10)
            .lineLimit(1)
            .truncationMode(.tail)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 0)
    }
}

//MARK: - 메뉴

struct MenuStruct {
    let title: String
    let icon: String
    let type: MenuType
    let action: () -> Void
    
    init(title: String, icon: String, type: MenuType = .normal, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.type = type
        self.action = action
    }
    
    enum MenuType {
        case normal
        case delete
    }
}

struct ContextMenu: View {
    let menuItems: [MenuStruct]
    let closeAction: () -> Void
    
    @State private var outOfScreenX: CGFloat = 0
    
    @State private var isAppeared: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(menuItems, id: \.title) { item in
                HStack {
                    Text(item.title)
                        .font(.pretendard(.regular, size: 15))
                        .foregroundStyle(item.type == .delete ? .red : .black)
                    
                    Spacer()
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 15))
                        .foregroundStyle(item.type == .delete ? .red : .black)
                }
                .background(Color(white: 230/255))
                .onTapGesture {
                    closeAction()
                    item.action()
                }
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .background(Color(white: 230/255))
        .frame(maxWidth: 200)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 0)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        if proxy.frame(in: .global).minX < 0 {
                            outOfScreenX = -proxy.frame(in: .global).minX + 10
                        } else if proxy.frame(in: .global).maxX > UIScreen.main.bounds.width {
                            outOfScreenX = UIScreen.main.bounds.width - proxy.frame(in: .global).maxX - 10
                        } else {
                            outOfScreenX = 0
                        }
                    }
            }
        )
        .offset(x: outOfScreenX)
        .scaleEffect(y: isAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                isAppeared = true
            }
        }
    }
}



