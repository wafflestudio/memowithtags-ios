//
//  ContextMenu.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/4/25.
//

import SwiftUI

struct MenuElement {
    let icon: String
    let title: String
    let type: MenuType
    let action: () -> Void
    
    init(icon: String, title: String, type: MenuType = .normal, action: @escaping () -> Void) {
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

struct ContextMenuView: View {
    let menuItems: [MenuElement]
    let isTopHalf: Bool
    let closeAction: () -> Void
    
    @State private var outOfScreenX: CGFloat = 0
    
    @State private var isAppeared: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(menuItems, id: \.title) { item in
                HStack {
                    Text(item.title)
                        .font(.pretendard(.regular, size: 15))
                        .foregroundStyle(item.type == .delete ? Color.redText : Color.basicText)
                    
                    Spacer()
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 15))
                        .foregroundStyle(item.type == .delete ? Color.redText : Color.basicText)
                }
                .background(Color.memoBackground)
                .onTapGesture {
                    closeAction()
                    item.action()
                }
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .background(Color.memoBackground)
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
        .scaleEffect(y: isAppeared ? 1 : 0, anchor: isTopHalf ? .top : .bottom)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                isAppeared = true
            }
        }
    }
}
