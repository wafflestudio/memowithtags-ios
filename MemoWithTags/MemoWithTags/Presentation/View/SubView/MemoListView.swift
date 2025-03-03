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
                        let isHighlighted: Bool = {
                            if viewModel.highlightingMemoIndex >= 0 &&
                               viewModel.highlightingMemoIndex < viewModel.recommendingMemoIds.count {
                                return viewModel.recommendingMemoIds[viewModel.highlightingMemoIndex] == memo.id
                            }
                            return false
                        }()
                        
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
            }
            .rotationEffect(.degrees(180))
            .scrollIndicators(.hidden)
            // highlightingMemoIndex 값이 바뀔 때, 해당 memoId를 보여주기 위해 (필요하다면 fetch 후) 스크롤
            .onChange(of: viewModel.highlightingMemoIndex) {
                Task {
                    if viewModel.highlightingMemoIndex != -1 {
                        let targetMemoId = viewModel.recommendingMemoIds[viewModel.highlightingMemoIndex]
                        // 만약 targetMemoId가 이미 memos에 있다면 fetch 없이 바로 스크롤
                        if viewModel.memos.contains(where: { $0.id == targetMemoId }) {
                            withAnimation {
                                proxy.scrollTo(targetMemoId, anchor: .center)
                            }
                        } else {
                            // memos에 없는 경우에만 fetch 후 스크롤
                            await viewModel.fetchMemosByMemoId()
                            withAnimation {
                                proxy.scrollTo(targetMemoId, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }
}
