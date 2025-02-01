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
                        let memoIsHighlighted = (highlightedMemoID == memo.id && isHighlighted)
                        
                        MemoView(memo: memo, viewModel: viewModel)
                            .id(memo.id)
                            .scaleEffect(memoIsHighlighted ? 1.04 : 1.0)
                            .shadow(color: memoIsHighlighted ? Color.black.opacity(0.2) : Color.black.opacity(0.05), radius: 6)
                            .animation(.easeInOut(duration: 0.3), value: isHighlighted)
                    }
                }
                .padding(.vertical, 20)
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: viewModel.scrollTarget) {
                handleScrollTargetChange(newTarget: viewModel.scrollTarget, proxy: proxy)
            }
            .onChange(of: viewModel.scrollSingleTarget) {
                guard let newSingleTarget = viewModel.scrollSingleTarget else { return }
                handleScrollSingleTargetChange(newSingleTarget: newSingleTarget, proxy: proxy)
            }

            .onChange(of: viewModel.recommendingMemos) {
                if viewModel.recommendingMemos.isEmpty {
                    highlightedMemoID = nil
                    isHighlighted = false
                }
            }
        }
    }
    
    private func handleScrollTargetChange(newTarget: Int, proxy: ScrollViewProxy) {
        highlightedMemoID = nil
        isHighlighted = false

        if newTarget > 0 {
            let recommendedMemos = viewModel.getSortedRecommendedMemos()
            guard recommendedMemos.indices.contains(newTarget - 1) else { return }
            let targetMemoID = recommendedMemos[newTarget - 1].id

            withAnimation {
                proxy.scrollTo(targetMemoID, anchor: .center)
            }
            
            DispatchQueue.main.async {
                highlightedMemoID = targetMemoID
                isHighlighted = true
            }
        }
    }

    private func handleScrollSingleTargetChange(newSingleTarget: UUID, proxy: ScrollViewProxy) {
        
        // newSingleTarget 이 nil이 아닐 때
        
        withAnimation {
            proxy.scrollTo(newSingleTarget, anchor: .center)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            highlightedMemoID = newSingleTarget
            isHighlighted = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            highlightedMemoID = nil
            isHighlighted = false
        }
    }
    
}

