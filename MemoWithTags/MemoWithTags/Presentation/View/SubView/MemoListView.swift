import SwiftUI

struct MemoListView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var highlightedMemoID: UUID? = nil
    @State private var isHighlighted: Bool = false  // 강조 애니메이션을 위한 상태
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sortedMemos) { memo in
                        MemoView(memo: memo, viewModel: viewModel)
                            .id(memo.id)
                            .scaleEffect(highlightedMemoID == memo.id && isHighlighted ? 1.05 : 1.0)  // 커졌다가 원래 크기로
                            .animation(.easeInOut(duration: 0.3), value: isHighlighted)
                    }
                }
                .padding(.vertical, 20)
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: viewModel.scrollTarget) {
                if viewModel.scrollTarget > 0 {
                    let targetMemoID = viewModel.recommendingMemos[viewModel.scrollTarget - 1].id
                    
                    withAnimation {
                        proxy.scrollTo(targetMemoID, anchor: .center)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        highlightedMemoID = targetMemoID
                        isHighlighted = true
                        
                        // 0.3초 후 원래 크기로 복귀
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isHighlighted = false
                        }
                        
                        // 1.5초 후 강조 배경 제거
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                highlightedMemoID = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var sortedMemos: [Memo] {
        switch viewModel.sortMemo {
        case .byCreate:
            return viewModel.memos.sorted { (memo1: Memo, memo2: Memo) -> Bool in
                return memo1.createdAt < memo2.createdAt
            }
        case .byUpdate:
            return viewModel.memos.sorted { (memo1: Memo, memo2: Memo) -> Bool in
                return memo1.updatedAt < memo2.updatedAt
            }
        }
    }
}

