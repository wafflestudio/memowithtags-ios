import SwiftUI
import Factory

struct MemoListView: View {
    @InjectedObservable(\.mainViewModel) private var viewModel
    
    var body: some View {
        List {
            ForEach(viewModel.memos) { memo in
                MemoView(memo: memo)
                    .id(memo.id)
                    .plainListCell()
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .rotationEffect(.degrees(180))
                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: -2)
            }

            Color.clear
                .frame(height: 8)
                .plainListCell()
                .onAppear {
                    Task {
                        if viewModel.memos.count > 0 {
                            await viewModel.fetchMemos()
                        }
                    }
                }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .rotationEffect(.degrees(180))
        .scrollIndicators(.hidden)
    }
}


extension View {
    func plainListCell() -> some View {
        listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

//struct MemoListView: View {
//    let reversed: Bool = true
//    
//    @InjectedObservable(\.mainViewModel) private var viewModel
//    
//    @State private var expandedMemoSet: Set<Int> = []
//    
//    var body: some View {
//        ScrollViewReader { proxy in
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 12) {
//                    Color.clear
//                        .frame(height: 8)
//                        .id("bottom")
//                    
//                    ForEach(viewModel.memos) { memo in
//                        MemoView(memo: memo, isExpanded: expandedMemoSet.contains(memo.id))
//                            .id(memo.id)
//                            .rotationEffect(.degrees(reversed ? 180 : 0))
//                            .padding(.horizontal, 12)
//                            .onTapGesture {
//                                toggleExpansion(for: memo.id)
//                            }
//                    }
//                    
//                    Color.clear
//                        .frame(height: 8)
//                        .onAppear {
//                            Task {
//                                if viewModel.memos.count > 0 {
//                                    await viewModel.fetchMemos()
//                                }
//                            }
//                        }
//                }
//            }
//            .rotationEffect(.degrees(reversed ? 180 : 0))
//            .scrollIndicators(.hidden)
//            .animation(.spring, value: expandedMemoSet)
////            .onChange(of: viewModel.scrollTrigger) {
////                withAnimation(.easeInOut(duration: 0.2)) {
////                    if viewModel.scrollTarget == -1 {
////                        proxy.scrollTo("bottom", anchor: .bottom)
////                    } else {
////                        proxy.scrollTo(viewModel.scrollTarget, anchor: .top)
////                    }
////                }
////            }
////            .onChange(of: viewModel.scrollTarget) {
////                Task {
////                    if viewModel.scrollTarget == -1 {
////                    } else {
////                        if viewModel.memos.contains(where: { $0.id == viewModel.scrollTarget }) {
////                            // scrollTarget이 이미 memos에 있다면 바로 스크롤
////                            withAnimation {
////                                proxy.scrollTo(viewModel.scrollTarget, anchor: .center)
////                            }
////                        } else {
////                            // scrollTarget이 memos에 없다면
////                            // 해당하는 memo가 나올 때까지 fetchMemos()를 반복 실행하고, 찾으면 그 메모로 scroll
////                            while !viewModel.memos.contains(where: { $0.id == viewModel.scrollTarget }) {
////                                await viewModel.fetchMemos()
////                            }
////                            // fetchMemo가 된 것이 View에 반영될 때까지 0.1초 기다리기
////                            try? await Task.sleep(nanoseconds: 100_000_000)
////                            withAnimation {
////                                proxy.scrollTo(viewModel.scrollTarget, anchor: .center)
////                            }
////                        }
////                    }
////                }
////            }
////            // highlightingMemoIndex 값이 바뀔 때, 그에 맞춰서 scrollTarget을 바꿈
////            .onChange(of: viewModel.highlightingMemoIndex) {
////                if viewModel.highlightingMemoIndex == -1 {
////                    viewModel.scrollTarget = -1
////                } else {
////                    viewModel.scrollTarget = viewModel.recommendingMemoIds[viewModel.highlightingMemoIndex]
////                }
////            }
//        }
//    }
//    
//    private func toggleExpansion(for id: Int) {
//        if expandedMemoSet.contains(id) {
//            expandedMemoSet.remove(id)
//        } else {
//            expandedMemoSet.insert(id)
//        }
//    }
//}
