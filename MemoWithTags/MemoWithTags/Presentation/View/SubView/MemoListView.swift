import SwiftUI

struct MemoListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12) {
                //MARK: - 메모 리스트
                ForEach(viewModel.memos) { memo in
                    MemoView(memo: memo, viewModel: viewModel)
                        .rotationEffect(.degrees(180))
                        .id(memo.id)
                }
                
                //MARK: - 스크롤 맨 위 로딩 아이콘
                HStack {
                    Spacer()
                    ProgressView()
                        .opacity(viewModel.isLoading ? 1 : 0)
                    Spacer()
                }.onAppear {
                    Task {
                        await viewModel.fetchMemos()
                    }
                }
            }

        }
        .rotationEffect(.degrees(180))
        
    }
}
