//import SwiftUI
//
//struct MemoListView: View {
//    @ObservedObject var viewModel: MainViewModel
//    
//    var body: some View {
//        ScrollViewReader { proxy in
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 12) {
//                    
//                    ForEach(viewModel.memos) { memo in
//                        let isHighlighted: Bool = {
//                            if viewModel.scrollTarget >= 0 {
//                                return viewModel.scrollTarget == memo.id
//                            }
//                            return false
//                        }()
//                        
//                        MemoView(memo: memo, viewModel: viewModel)
//                            .id(memo.id)
//                            .scaleEffect(isHighlighted ? 1.04 : 1.0)
//                            .shadow(color: isHighlighted ? Color.shadow : .clear, radius: 3)
//                            .animation(.easeInOut(duration: 0.3), value: isHighlighted)
//                            .rotationEffect(.degrees(180))
//                    }
//                    
//                    // ProgressView: 스크롤 맨 위(화면 상단, 코드 상에서는 아래쪽)에 도달하면 다음 페이지를 불러옴 (fetchMemos())
//                    HStack {
//                        Spacer()
//                        ProgressView()
//                        Spacer()
//                    }
//                    .opacity(viewModel.isLoading ? 1 : 0)
//                    .onAppear {
//                        Task {
//                            await viewModel.fetchMemos()
//                        }
//                    }
//                }
//                .padding(.top, 20) // 화면 하단, 코드 상으로는 top에 패딩
//            }
//            .rotationEffect(.degrees(180))
//            .scrollIndicators(.hidden)
//            // scrollTarget 값이 바뀔 때, 해당 memoId를 보여주기 위해 (필요하다면 fetch 후) 스크롤
//            .onChange(of: viewModel.scrollTarget) {
//                Task {
//                    if viewModel.scrollTarget == -1 {
//                        if let firstMemo = viewModel.memos.first {
//                            withAnimation {
//                                proxy.scrollTo(firstMemo.id, anchor: .center)
//                            }
//                        }
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
//        }
//    }
//}
