//
//  Preview.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/4/25.
//

import SwiftUI
import Flow
import Factory

enum PreviewType {
    case memo(memo: Memo)
    case tag(tag: Tag)
}

struct Preview: View {
    let type: PreviewType
    let position: CGRect
    
    var body: some View {
        switch type {
        case .memo(let memo):
            MemoPreview(memo: memo, position: position)
        case .tag(let tag):
            TagPreview(tag: tag)
        }
    }
}

struct MemoPreview: View {
    let memo: Memo
    let position: CGRect
    
    @InjectedObservable(\.appState) private var appState
    
    @State private var newHeight: CGFloat = 0
    @State private var isAppeared: Bool = false

    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(memo.content)
                .font(.pretendard(.regular, size: 14))
                .foregroundColor(Color.basicText)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Spacer()
            
            if !memo.tagIds.isEmpty {
                HFlow {
                    ForEach(memo.tagIds.toTags(from: appState.tags), id: \.id) { tag in
                        Text(tag.name)
                            .font(.pretendard(.regular, size: 13))
                            .foregroundColor(Color.tagText)
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
            
            HStack(alignment: .bottom) {
                if memo.locked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color.grayText)
                        .font(.system(size: 14))
                }
                
                Text(dateFormat(date: memo.createdAt))
                    .font(.pretendard(.medium, size: 11))
                    .foregroundStyle(Color.grayText)
                    .padding(.vertical, 3)
                
                Spacer()
            }
            
            
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 17)
        .frame(width: position.width, height: isAppeared ? newHeight : position.height)
        .background(Color.memoBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 0)
        .onAppear {
            if position.height > 200 {
                newHeight = 200
            } else {
                newHeight = position.height + 50
            }
            
            withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                isAppeared = true
            }
        }
    }
    
    func dateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
}

struct TagPreview: View {
    let tag: Tag
    
    var body: some View {
        Text(tag.name)
            .font(.pretendard(.regular, size: 15))
            .foregroundColor(Color.tagText)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(tag.color.color)
            .cornerRadius(10)
            .lineLimit(1)
            .truncationMode(.tail)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 0)
    }
}
