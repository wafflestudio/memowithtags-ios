import SwiftUI

struct MemoListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.memos) { memo in
                    MemoView(memo: memo, viewModel: viewModel)
                        .id(memo.id)
                        .rotationEffect(.degrees(180))
                }
            }
            .padding(.bottom, 20)
            .rotationEffect(.degrees(180))

        }
        .defaultScrollAnchor(.bottom)
        
    }
}
