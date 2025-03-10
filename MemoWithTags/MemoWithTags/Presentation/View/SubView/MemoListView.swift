import SwiftUI

struct MemoListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    
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
                    
                    // ProgressView: 스크롤 맨 위(화면 상단, 코드 상에서는 아래쪽)에 도달하면 다음 페이지를 불러옴 (fetchMemos())
                    ProgressView()
                        .opacity(viewModel.isLoading ? 1 : 0)
                        .onAppear {
                            Task {
                                await viewModel.fetchMemos()
                            }
                        }
                }
                .padding(.top, 20) // 화면 하단, 코드 상으로는 top에 패딩
            }
            .rotationEffect(.degrees(180))
            .scrollIndicators(.hidden)
            
            // highlightingMemoIndex 값이 바뀔 때, 해당 memoId를 보여주기 위해 (필요하다면 fetch 후) 스크롤
            .onChange(of: viewModel.highlightingMemoIndex) {
                Task {
                    if viewModel.highlightingMemoIndex == -1 {
                        if let firstMemo = viewModel.memos.first {
                            withAnimation {
                                proxy.scrollTo(firstMemo.id, anchor: .center)
                            }
                        }
                    } else {
                        let targetMemoId = viewModel.recommendingMemoIds[viewModel.highlightingMemoIndex]
                        // targetMemoId가 이미 memos에 있다면 바로 스크롤
                        if viewModel.memos.contains(where: { $0.id == targetMemoId }) {
                            withAnimation {
                                proxy.scrollTo(targetMemoId, anchor: .center)
                            }
                        } else {
                            // targetMemoId가 memos에 없다면
                            // 해당하는 memo가 나올 때까지 fetchMemos()를 반복 실행하고, 찾으면 그 메모로 scroll
                            while !viewModel.memos.contains(where: { $0.id == targetMemoId }) {
                                await viewModel.fetchMemos()
                            }
                            // fetchMemo가 된 것이 View에 반영될 때까지 0.1초 기다리기
                            try? await Task.sleep(nanoseconds: 100_000_000)
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
