//
//  SearchViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/21/25.
//

import Foundation
import SwiftUI
import Factory

@MainActor
@Observable
final class SearchViewModel {
    @ObservationIgnored @Injected(\.memoService) private var memoService: MemoService
    @Injected(\.appState) private var appState: AppState
    @Injected(\.navigation) private var navigation: Navigation
    @Injected(\.alert) private var alert: Alert
    
    var isLoading: Bool = false
    
    var searchBarText: String = ""
    var currentPage: Int = 0
    var totalPages: Int = 1

    var searchedMemos: [Memo] = []
    var searchedTagIds: [Int] = []
    var searchBarSelectedTagIds: [Int] = []
    
    func searchMemos(content: String? = nil, tagIds: [Int]? = nil, dateRange: ClosedRange<Date>? = nil) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let nextPage = currentPage + 1
        
        guard nextPage <= totalPages else {
            isLoading = false
            return
        }
        
        let result = await memoService.searchMemos(content: content, tagIds: tagIds, dateRange: dateRange, page: nextPage)
        
        switch result {
        case .success(let paginatedMemos):
            searchedMemos.append(contentsOf: paginatedMemos.memos)
            currentPage = nextPage
            totalPages = paginatedMemos.totalPages
            
        case .failure(let error):
            // SearchView에서 wait이 끝나고 searchMemo가 실행되는 와중에 새로운 Task가 생성되어서 Task가 사라지면 MemoError.unknown이 뜬다. 이것은 정상적인 결과이기 때문에 무시한다.
            if (error != MemoError.unknown) {
                alert.alert(error: error)
            }
        }
        
        isLoading = false
    }
    
    //MARK: - 새로운 검색어, 태그에 대한 검색 수행
    func search() async {
        // 이전 검색 결과를 모두 리셋
        searchedMemos = []
        searchedTagIds = []
        currentPage = 0
        totalPages = 1
        
        let trimmedText = searchBarText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedText.isEmpty || !searchBarSelectedTagIds.isEmpty {
            await searchMemos(content: trimmedText, tagIds: searchBarSelectedTagIds)
            
            // 검색창의 text에 맞는 tag를 local에서 찾아서 반환
            let searchedTags = tags.filter { tag in
                tag.name.lowercased().contains(trimmedText.lowercased()) && !searchBarSelectedTagIds.contains(tag.id)
            }
            
            searchedTagIds = searchedTags.map { $0.id }
        }
    }
}

extension Container {
    @MainActor
    var searchViewModel: Factory<SearchViewModel> {
        self { @MainActor in SearchViewModel() }.singleton
    }
}
