//
//  EditingTagListView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/6/25.
//

import SwiftUI
import Factory


struct TagEditorView: View {
    @InjectedObservable(\.mainViewModel) private var viewModel
    
    @State private var searchText: String = ""
    @State private var randomColor: Color.TagColor = Color.TagColor.allCases.randomElement()!
    
    //animation
    @State private var isAppear: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // 태그 검색하는 필드
            TextField("태그 찾기", text: $searchText)
                .font(.pretendard(.regular, size: 14))
                .foregroundColor(Color.placeholder)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .frame(maxWidth: 80)
                .background(Color.searchBarBackground)
                .cornerRadius(20)
            
            // Divider Line
            Rectangle()
                .foregroundColor(Color.placeholder)
                .frame(width: 0.3, height: 32)
            
            // 태그 추천해주는 스크롤 라인
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 8) {
                    // "Create Tag" TagView
                    if canCreateTag() {
                        HStack(alignment: .center, spacing: 4) {
                            Text(searchText)
                                .font(.pretendard(.regular, size: 14))
                                .foregroundColor(Color.tagText)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(randomColor.color)
                                .cornerRadius(4)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Text("만들기")
                                .font(.pretendard(.regular, size: 14))
                                .foregroundStyle(Color.basicText)
                        }
                        .onTapGesture {
                            Task {
                                await viewModel.createTag(name: searchText, color: randomColor)
                                searchText = ""
                                generateRandomHexColor()
                            }
                        }
                    }
                    
                    ForEach(viewModel.tags, id: \.id) { tag in
                        TagView(tag: tag) {
                            searchText = ""
                            if !viewModel.editTagList.contains(tag.id) {
                                viewModel.editTagList.append(tag.id)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .opacity(isAppear ? 1 : 0)
        .animation(.smooth(duration: 0.5).delay(0.3), value: isAppear)
        .onAppear {
            generateRandomHexColor()
            isAppear = true
        }
        .onDisappear {
            isAppear = false
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
