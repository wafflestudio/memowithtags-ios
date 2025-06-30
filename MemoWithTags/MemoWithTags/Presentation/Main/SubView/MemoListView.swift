import SwiftUI
import Factory

struct MemoListView: View {
    @InjectedObservable(\.mainViewModel) private var viewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    Color.clear
                        .frame(height: 8)
                        .id("bottom")
                    
                    ForEach(viewModel.memos) { memo in
                        MemoView(memo: memo)
                            .id(memo.id)
//                            .scaleEffect(isHighlighted ? 1.04 : 1.0)
//                            .shadow(color: isHighlighted ? Color.shadow : .clear, radius: 3)
//                            .animation(.easeInOut(duration: 0.3), value: isHighlighted)
                            .rotationEffect(.degrees(180))
                    }
                    
                    Color.clear
                        .frame(height: 8)
                        .onAppear {
                            Task {
                                if viewModel.memos.count > 0 {
                                    await viewModel.fetchMemos()
                                }
                            }
                        }
                }
            }
            .rotationEffect(.degrees(180))
            .scrollIndicators(.hidden)
            .onChange(of: viewModel.scrollTrigger) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if viewModel.scrollTarget == -1 {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    } else {
                        proxy.scrollTo(viewModel.scrollTarget, anchor: .top)
                    }
                }
            }
//            .onChange(of: viewModel.scrollTarget) {
//                Task {
//                    if viewModel.scrollTarget == -1 {
//                    } else {
//                        if viewModel.memos.contains(where: { $0.id == viewModel.scrollTarget }) {
//                            // scrollTarget이 이미 memos에 있다면 바로 스크롤
//                            withAnimation {
//                                proxy.scrollTo(viewModel.scrollTarget, anchor: .center)
//                            }
//                        } else {
//                            // scrollTarget이 memos에 없다면
//                            // 해당하는 memo가 나올 때까지 fetchMemos()를 반복 실행하고, 찾으면 그 메모로 scroll
//                            while !viewModel.memos.contains(where: { $0.id == viewModel.scrollTarget }) {
//                                await viewModel.fetchMemos()
//                            }
//                            // fetchMemo가 된 것이 View에 반영될 때까지 0.1초 기다리기
//                            try? await Task.sleep(nanoseconds: 100_000_000)
//                            withAnimation {
//                                proxy.scrollTo(viewModel.scrollTarget, anchor: .center)
//                            }
//                        }
//                    }
//                }
//            }
//            // highlightingMemoIndex 값이 바뀔 때, 그에 맞춰서 scrollTarget을 바꿈
//            .onChange(of: viewModel.highlightingMemoIndex) {
//                if viewModel.highlightingMemoIndex == -1 {
//                    viewModel.scrollTarget = -1
//                } else {
//                    viewModel.scrollTarget = viewModel.recommendingMemoIds[viewModel.highlightingMemoIndex]
//                }
//            }
        }
    }
}
