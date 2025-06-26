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
    @ObservationIgnored @Injected(\.memoService) private var memoService
    @ObservationIgnored @Injected(\.appState) private var appState
    @ObservationIgnored @Injected(\.navigationState) private var navigation
    @ObservationIgnored @Injected(\.alertState) private var alert
    
    var isLoading: Bool = false
    
    var currentPage: Int = 0
    var totalPages: Int = 1

    var searchedMemos: [Memo] = []
    var searchedTags: [Tag] = []

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
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 새로운 검색어, 태그에 대한 검색 수행
    func search(text: String, tagIds: [Int]) async {
        searchedMemos = []
        searchedTags = []
        currentPage = 0
        totalPages = 1
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedText.isEmpty || !tagIds.isEmpty {
            await searchMemos(content: trimmedText, tagIds: tagIds)
            
            searchedTags = appState.tags.filter { tag in
                tag.name.lowercased().contains(trimmedText.lowercased()) && !tagIds.contains(tag.id)
            }
        }
    }
}

extension Container {
    @MainActor
    var searchViewModel: Factory<SearchViewModel> {
        self { @MainActor in SearchViewModel() }.singleton
    }
}
