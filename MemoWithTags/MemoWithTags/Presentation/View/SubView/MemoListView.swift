import SwiftUI

struct MemoListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.memos.reversed()) { memo in
                        if #available(iOS 18.0, *) {
                            MemoView(memo: memo, viewModel: viewModel)
                                .id(memo.id)
                        } else {
                            //
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: viewModel.scrollTarget) {
                if viewModel.scrollTarget > 0 {
                    withAnimation {
                        proxy.scrollTo(viewModel.recommendingMemos[viewModel.scrollTarget - 1].id, anchor: .center)
                    }
                }
            }
        }
        
    }
}
