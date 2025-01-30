import SwiftUI

struct MemoListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.memos.reversed()) { memo in
                    if #available(iOS 18.0, *) {
                        MemoView(memo: memo, viewModel: viewModel)
                            .id(memo.id)
                    } else {
                        // 애니메이션이 일단 ios18만 지원되는 상태..
                    }
                }
            }
            .padding(.bottom, 20)

        }
        .defaultScrollAnchor(.bottom)
        
    }
}
