import SwiftUI

struct MemoListView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var highlightedMemoID: UUID? = nil
    @State private var isHighlighted: Bool = false  // 강조 애니메이션을 위한 상태
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.getSortedMemos()) { memo in
                        MemoView(memo: memo, viewModel: viewModel)
                            .id(memo.id)
                            .scaleEffect(highlightedMemoID == memo.id && isHighlighted ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isHighlighted)
                    }
                }
                .padding(.vertical, 20)
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: viewModel.scrollTarget) {
                highlightedMemoID = nil
                isHighlighted = false
                
                if viewModel.scrollTarget > 0 {
                    let targetMemoID = viewModel.getSortedRecommendedMemos()[viewModel.scrollTarget - 1].id
                    
                    withAnimation {
                        proxy.scrollTo(targetMemoID, anchor: .center)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        highlightedMemoID = targetMemoID
                        isHighlighted = true
                    }
                }
            }
            .onChange(of: viewModel.recommendingMemos) {
                if viewModel.recommendingMemos.isEmpty {
                    highlightedMemoID = nil
                    isHighlighted = false
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

