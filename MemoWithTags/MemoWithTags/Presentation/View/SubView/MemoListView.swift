import SwiftUI

struct MemoListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    
                    // ProgressView: 스크롤 바닥(화면 아래, 코드 상에서는 위쪽)에 도달하면 이전 페이지(fetchMemos(direction: .previous))를 불러옴
                    ProgressView()
                        .opacity(viewModel.isLoading ? 1 : 0)
                        .onAppear {
                            Task {
                                await viewModel.fetchMemos(direction: .previous)
                            }
                        }
                    
                    //MARK: - 메모 리스트
                    ForEach(viewModel.memos) { memo in
                        let isHighlighted = viewModel.recommendingMemoIds.indices.contains(viewModel.highlightingMemoIndex) &&
                                            viewModel.recommendingMemoIds[viewModel.highlightingMemoIndex] == memo.id
                        
                        MemoView(memo: memo, viewModel: viewModel)
                            .rotationEffect(.degrees(180))
                            .id(memo.id)
                            .scaleEffect(isHighlighted ? 1.04 : 1.0)
                            .shadow(color: isHighlighted ? Color.black.opacity(0.2) : Color.black.opacity(0.05), radius: 6)
                            .animation(.easeInOut(duration: 0.3), value: isHighlighted)
                    }
                    
                    // ProgressView: 스크롤 맨 위(화면 상단, 코드 상에서는 아래쪽)에 도달하면 다음 페이지(fetchMemos(direction: .next))를 불러옴
                    ProgressView()
                        .opacity(viewModel.isLoading ? 1 : 0)
                        .onAppear {
                            Task {
                                await viewModel.fetchMemos(direction: .next)
                            }
                        }
                }
                .padding(.top, 20)
            }
            .rotationEffect(.degrees(180))
            .scrollIndicators(.hidden)
            // highlightingMemoIndex 값이 바뀔 때, 해당 memoId를 기준으로 fetch 후 스크롤
            .onChange(of: viewModel.highlightingMemoIndex) {
                Task {
                    if viewModel.highlightingMemoIndex != -1 {
                        await viewModel.fetchMemosByMemoId()
                        let targetMemoId = viewModel.recommendingMemoIds[viewModel.highlightingMemoIndex]
                        proxy.scrollTo(targetMemoId, anchor: .center)
                    }
                }
            }
        }
    }
}
