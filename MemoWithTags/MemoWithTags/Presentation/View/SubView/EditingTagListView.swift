//
//  EditingTagListView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/6/25.
//

import SwiftUI

struct EditingTagListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    @State private var searchText: String = ""
    @State private var randomColor: Color.TagColor = Color.TagColor.allCases.randomElement()!
    
    // 상태 변수를 sheet(item:)에 맞게 수정
    @State private var updatingTag: Tag? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // 태그 검색하는 필드
            TextField("태그 검색", text: $searchText)
                .font(.custom("Pretendard", size: 16))
                .foregroundColor(Color.searchBarPlaceholderGray)
                .frame(maxWidth: 80)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.searchBarBackgroundGray)
                .cornerRadius(20)
            
            // Divider Line
            Rectangle()
                .foregroundColor(Color.dividerGray)
                .frame(width: 0.3, height: 32)
            
            // 태그 추천해주는 스크롤 라인
            ScrollView(.horizontal) {
                HStack(alignment: .center, spacing: 8) {
                    ForEach(filterTags(), id: \.id) { tag in
                        TagView(viewModel: viewModel, tag: tag) {
                            viewModel.editorTags.append(tag)
                        }
                    }
                    
                    // "Create Tag" TagView
                    if canCreateTag() {
                        CreateTagView(
                            searchText: $searchText,
                            randomColor: $randomColor
                        )
                        .onTapGesture {
                            Task {
                                await viewModel.createTag(name: searchText, color: randomColor)
                                searchText = ""
                                generateRandomHexColor()
                            }
                        }
                    }
                }
            }
            
            // Spacer()
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .onAppear {
            generateRandomHexColor()
        }
    }
    
    // Function to filter tags based on search text
    private func filterTags() -> [Tag] {
        if searchText.isEmpty {
            return viewModel.recommendTags()
        } else {
            return viewModel.recommendTags().filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    // Determine if a new tag can be created
    private func canCreateTag() -> Bool {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedText.isEmpty && !viewModel.tags.contains { $0.name.lowercased() == trimmedText.lowercased() }
    }
    
    // Generate a random HEX color string from TagColor enum
    private func generateRandomHexColor() {
        self.randomColor = Color.TagColor.allCases.randomElement()!
    }
}
