import SwiftUI
import Factory

struct MemoListView: View {
    @InjectedObservable(\.mainViewModel) private var viewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    Color.clear
                        .id("bottom")
                        .frame(height: 8)
                    
                    ForEach(viewModel.memos) { memo in
                        MemoView(memo: memo)
                            .id(memo.id)
                            .padding(.horizontal, 12)
                            .scaleEffect(viewModel.scrollTarget == memo.id ? 1.04 : 1.0)
                            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
                            .shadow(color: viewModel.scrollTarget == memo.id ? Color.shadow : .clear, radius: 3)
                            .rotationEffect(.degrees(180))
                    }
                    
                    ProgressView()
                        .opacity(viewModel.mainLoading ? 1 : 0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(5)
                        .onAppear {
                            Task {
                                await viewModel.fetchMemos()
                            }
                        }
                }
            }
            .rotationEffect(.degrees(180))
            .scrollIndicators(.hidden)
            .onChange(of: viewModel.scrollTrigger) {
                Task {
                    if viewModel.scrollTarget == -1 {
                        withAnimation(.easeInOut) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    } else {
                        if viewModel.memos.contains(where: { $0.id == viewModel.scrollTarget }) {
                            // scrollTarget이 이미 memos에 있다면 바로 스크롤
                            withAnimation(.easeInOut) {
                                proxy.scrollTo(viewModel.scrollTarget, anchor: .center)
                            }
                        } else {
                            // scrollTarget이 memos에 없다면
                            // 해당하는 memo가 나올 때까지 fetchMemos()를 반복 실행하고, 찾으면 그 메모로 scroll
                            while !viewModel.memos.contains(where: { $0.id == viewModel.scrollTarget }) {
                                await viewModel.fetchMemos()
                            }
                            // fetchMemo가 된 것이 View에 반영될 때까지 0.1초 기다리기
                            try? await Task.sleep(for: .seconds(0.1))
                            withAnimation(.easeInOut) {
                                proxy.scrollTo(viewModel.scrollTarget, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }
}

//struct MemoListView: View {
//    @InjectedObservable(\.mainViewModel) private var viewModel
//    
//    var body: some View {
//        List {
//            ForEach(viewModel.memos) { memo in
//                MemoView(memo: memo)
//                    .plainListCell()
//                    .padding(.vertical, 6)
//                    .padding(.horizontal, 12)
//                    .rotationEffect(.degrees(180))
//                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: -2)
//            }
//
//            Color.clear
//                .frame(height: 8)
//                .plainListCell()
//                .onAppear {
//                    Task {
//                        if viewModel.memos.count > 0 {
//                            await viewModel.fetchMemos()
//                        }
//                    }
//                }
//        }
//        .listStyle(.plain)
//        .scrollContentBackground(.hidden)
//        .background(Color.clear)
//        .rotationEffect(.degrees(180))
//        .scrollIndicators(.hidden)
//    }
//}


//extension View {
//    func plainListCell() -> some View {
//        listRowSeparator(.hidden)
//        .listRowInsets(EdgeInsets())
//        .listRowBackground(Color.clear)
//    }
//}
