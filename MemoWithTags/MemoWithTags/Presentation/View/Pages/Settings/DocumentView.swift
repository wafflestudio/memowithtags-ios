import SwiftUI

struct DocumentView: View {
    let title: String
    let content: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                Color.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Navigation Bar
                    HStack(spacing: 0) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 19))
                            .foregroundStyle(Color.soft)
                            .padding(12)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dismiss()
                            }
                        Text(title)
                            .font(.pretendard(.semibold, size: 18))
                            .foregroundStyle(Color.basicText)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    ScrollView {
                        Text(content)
                            .font(.pretendard(.regular, size: 13))
                            .foregroundStyle(Color.basicText)
                            .padding(16)
                    }
                    .background(Color.memoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 12)
            }
        }
    }
} 