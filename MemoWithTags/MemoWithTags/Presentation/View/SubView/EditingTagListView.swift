//
//  EditingTagListView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/6/25.
//

import SwiftUI

struct EditingTagListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    @State private var randomColor: Color.TagColor = Color.TagColor.allCases.randomElement()!
    
    // 상태 변수를 sheet(item:)에 맞게 수정
    @State private var updatingTag: Tag? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // 태그 검색하는 필드
            TextField("태그 검색", text: $viewModel.editorTagSearchBarText)
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
                    
                    let lowercasedEditorTagSearchBarText = viewModel.editorTagSearchBarText.lowercased()
                    
                    // editorTagSearchBarText와 정확히 일치하는 태그가 있는지 확인. 이것은 lowercase할 필요가 없다.
                    let isExactMatchExist = viewModel.recommendingTags.contains { tag in
                        tag.name == viewModel.editorTagSearchBarText
                    }
                    
                    // 1차로 editorTagSearchBarText의 검색어와 String Match 되는 tag들만 남김
                    let filteredBySearchText = viewModel.recommendingTags
                        .filter { tag in
                        let lowercasedTagName = tag.name.lowercased()
                        return lowercasedEditorTagSearchBarText.isEmpty || lowercasedTagName.contains(lowercasedEditorTagSearchBarText)
                    }
                    
                    // 2차로 editorTags에 있는 tag들 제거
                    let editorTagsFilteredTags = filteredBySearchText
                        .filter { tag in
                            !viewModel.editorTags.contains(where: { $0.id == tag.id })
                        }
                    
                    if !lowercasedEditorTagSearchBarText.isEmpty && !isExactMatchExist {
                        CreateTagView(
                            searchText: $viewModel.editorTagSearchBarText,
                            randomColor: $randomColor
                        )
                        .onTapGesture {
                            Task {
                                await viewModel.createTag(name: viewModel.editorTagSearchBarText, color: randomColor)
                                viewModel.editorTagSearchBarText = ""
                                generateRandomHexColor()
                            }
                        }
                    }
                    
                    // 필터링된 태그들을 ForEach로 표시
                    ForEach(editorTagsFilteredTags, id: \.id) { tag in
                        TagView(viewModel: viewModel, tag: tag) {
                            viewModel.editorTags.append(tag)
                        }
                    }
                    
                }
            }
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .onAppear {
            generateRandomHexColor()
        }
    }
    
    // Generate a random HEX color string from TagColor enum
    private func generateRandomHexColor() {
        self.randomColor = Color.TagColor.allCases.randomElement()!
    }
}
