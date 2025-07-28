//
//  MainViewModel.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/30/25.
//

import Foundation
import SwiftUI
import Factory

@MainActor
@Observable
final class MainViewModel {
    @ObservationIgnored @Injected(\.memoService) private var memoService
    @ObservationIgnored @Injected(\.tagService) private var tagService
    @ObservationIgnored @Injected(\.userService) private var userService
    
    @ObservationIgnored @Injected(\.appState) private var appState
    @ObservationIgnored @Injected(\.navigationState) private var navigation
    @ObservationIgnored @Injected(\.alertState) private var alert
    
    //main
    var memos: [Memo] = []
    func tags(for tagIds: [TagID]) -> [Tag] { appState.tags(for: tagIds) }
    
    private var mainCurrentPage: Int = 0
    private var mainTotalPages: Int = 1
    
    var mainLoading: Bool = false
    
    var scrollTrigger: Bool = false
    var scrollTarget: Int = -1
    
    var recommendingMemoIds: [Int] = []
    var highlightingMemoIndex: Int = -1
    
    //search
    var searchLoading: Bool = false
    private var searchTask: Task<Void, Never>?
    
    var searchContent: String = ""
    var searchContentTags: [TagID] = []
    var searchedMemos: [Memo] = []
    var searchedTags: [TagID] = []
    
    private var searchCurrentPage: Int = 0
    private var searchTotalPages: Int = 1
    
    //editor
    var editContent: String = ""
    var editTags: [TagID] = []
    var editState: EditState = .create
    var editLoading: Bool = false
    private var editTask: Task<Void, Never>?
    
    
    
    //MARK: - 메모 페이지 별로 가져오기
    func fetchMemos() async {
        guard !mainLoading else { return }
        
        mainLoading = true
        
        let nextPage = mainCurrentPage + 1
        
        guard nextPage <= mainTotalPages else {
            mainLoading = false
            return
        }
        
        let result = await memoService.searchMemos(content: nil, tagIds: nil, dateRange: nil, page: nextPage)
        
        switch result {
        case .success(let paginatedMemos):
            memos.append(contentsOf: paginatedMemos.memos)
            mainCurrentPage = nextPage
            mainTotalPages = paginatedMemos.totalPages
            mainLoading = false
            
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
    //MARK: - 메모 생성
    func createMemo(content: String, tagIds: [Int], locked: Bool) async {
        let result = await memoService.createMemo(content: content, tagIds: tagIds, locked: locked)
        
        switch result {
        case .success(let memo):
            let mainPrefetched = await prefetchMainMemo()
            
            if mainPrefetched != nil && memos.contains(mainPrefetched!) {
                memos.removeAll { $0.id == mainPrefetched!.id }
            }
            
            memos.insert(memo, at: 0)
            
        case .failure(let error):
            if error.type != .ignore {
                alert.alert(error: error)
            }
        }
    }
    
    //MARK: - 메모 수정
    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async {
        let result = await memoService.updateMemo(memoId: memoId, content: content, tagIds: tagIds, locked: locked)
        
        switch result {
        case .success(let memo):
            if let index = memos.firstIndex(where: { $0.id == memo.id }) {
                memos[index] = memo
            }
            if let index = searchedMemos.firstIndex(where: { $0.id == memo.id }) {
                searchedMemos[index] = memo
            }
            
        case .failure(let error):
            if error.type != .ignore {
                alert.alert(error: error)
            }
        }
    }
    
    
    //MARK: - 메모 삭제
    func deleteMemo(memoId: Int) async {
        let mainPrefetched = await prefetchMainMemo()
        let searchPrefetched = await prefetchSearchedMemo()
        
        let result = await memoService.deleteMemo(memoId: memoId)
        
        switch result {
        case .success:
            var beforeCount = memos.count
            memos.removeAll { $0.id == memoId }
            if beforeCount != memos.count && mainPrefetched != nil {
                memos.append(mainPrefetched!)
            }
 
            beforeCount = searchedMemos.count
            searchedMemos.removeAll { $0.id == memoId }
            if beforeCount != searchedMemos.count && searchPrefetched != nil{
                searchedMemos.append(searchPrefetched!)
            }
            
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
    // MARK: - 페이지네이션 관련 조정 함수들
    func prefetchMainMemo() async -> Memo? {
        guard mainCurrentPage + 1 <= mainTotalPages else { return nil }
        
        let resultMain = await memoService.searchMemos(content: nil, tagIds: nil, dateRange: nil, page: mainCurrentPage + 1)
        
        switch resultMain {
        case .success(let paginatedMemos):
            return paginatedMemos.memos.first
            
        case .failure(let error):
            alert.alert(error: error)
            return nil
        }
    }
    
    func prefetchSearchedMemo() async -> Memo? {
        let content = searchContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !content.isEmpty || !searchContentTags.isEmpty else { return nil }
        guard searchCurrentPage + 1 <= searchTotalPages else { return nil }
        
        let resultSearch = await memoService.searchMemos(content: content, tagIds: searchContentTags, dateRange: nil, page: searchCurrentPage + 1)
        
        switch resultSearch {
        case .success(let paginatedMemos):
            return paginatedMemos.memos.first
        case .failure(let error):
            alert.alert(error: error)
            return nil
        }
    }
    
    // MARK: - 추천 메모 ID 가져오기
    func recommendMemos() async {
        self.recommendingMemoIds = []
        self.highlightingMemoIndex = -1
        self.scrollTarget = -1
        
        if editTags.isEmpty { return }
        
        let result = await memoService.recommendMemos(content: editContent, tagIds: editTags)
        
        switch result {
        case .success(let recommendedMemoIds):
            var ids = recommendedMemoIds.memoIds
            // .update 상태인 경우, 업데이트 대상 memo id는 recommendedMemoIds에서 제외
            if case let .update(target) = editState {
                ids.removeAll { $0 == target.id }
            }
            self.recommendingMemoIds = ids
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
    //MARK: - 태그 생성
    func createTag(name: String, color: Color.TagColor) async -> TagID? {
        let result = await tagService.createTag(name: name, color: color)
        
        switch result {
        case .success(let tag):
            appState.tags.append(tag)
            return tag.id
            
        case .failure(let error):
            alert.alert(error: error)
        }
        
        return nil
    }
    
    //MARK: - 태그 수정
    func updateTag(tagId: Int, name: String, color: Color.TagColor) async {
        let result = await tagService.updateTag(tagId: tagId, name: name, color: color)
        
        switch result {
        case .success(let tag):
            if let index = appState.tags.firstIndex(where: { $0.id == tagId }) {
                appState.tags[index] = tag
            }
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
    //MARK: - 태그 삭제
    func deleteTag(tagId: Int) async {
        let result = await tagService.deleteTag(tagId: tagId)
        
        switch result {
        case .success:
            appState.tags.removeAll { $0.id == tagId }

            for index in memos.indices {
                memos[index].tagIds.removeAll { $0 == tagId }
            }
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
    //MARK: - 새로운 검색어, 태그에 대한 검색 수행
    func search() async {
        searchTask?.cancel()
        searchTask = Task {
            searchLoading = true
            
            defer {
                if !Task.isCancelled {
                    searchLoading = false
                }
            }
            
            do {
                try Task.checkCancellation()
                try await Task.sleep(for: .seconds(0.5))
                
                searchedMemos = []
                searchedTags = []
                searchCurrentPage = 0
                searchTotalPages = 1
                
                let trimmedText = searchContent.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !trimmedText.isEmpty || !searchContentTags.isEmpty {
                    await searchMemos(content: trimmedText, tagIds: searchContentTags)
                    
                    searchedTags = appState.tags.filter { tag in
                        tag.name.lowercased().contains(trimmedText.lowercased()) &&
                        !searchContentTags.contains(tag.id)
                    }.map(\.id)
                }
            } catch {
            }
        }
    }
    
    func searchMemos(content: String? = nil, tagIds: [Int]? = nil, dateRange: ClosedRange<Date>? = nil) async {
        let nextPage = searchCurrentPage + 1
        
        guard nextPage <= searchTotalPages else {
            return
        }
        
        let result = await memoService.searchMemos(content: content, tagIds: tagIds, dateRange: dateRange, page: nextPage)
        
        switch result {
        case .success(let paginatedMemos):
            searchedMemos.append(contentsOf: paginatedMemos.memos)
            searchCurrentPage = nextPage
            searchTotalPages = paginatedMemos.totalPages
            
        case .failure(let error):
            if error.type != .ignore {
                alert.alert(error: error)
            }
        }
    }
    
    //MARK: - editor에서 submit 했을 때 작동
    func saveMemo(content: String, tags: [TagID], editState: EditState, auto: Bool = false) async {
        editTask?.cancel()
        editTask = Task {
            editLoading = true
            
            defer {
                if !Task.isCancelled {
                    editLoading = false
                }
            }
            
            do {
                try Task.checkCancellation()
                let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedContent.isEmpty {
                    if auto {
                        try await Task.sleep(for: .seconds(2))
                    } else {
                        self.editContent = ""
                        self.editTags = []
                        self.editState = .create
                        self.scrollTo(memoID: nil)
                        hideKeyboard()
                    }
                    
                    switch editState {
                    case .create:
                        await createMemo(content: trimmedContent, tagIds: tags, locked: false)
                    case .update(let target):
                        await updateMemo(memoId: target.id, content: trimmedContent, tagIds: tags, locked: target.locked)
                    }
                }

            } catch {
            }
        }
    }
    
    func scrollTo(memoID: Int?) {
        scrollTrigger.toggle()
        if memoID == nil {
            scrollTarget = -1
        } else {
            scrollTarget = memoID!
        }
    }
}

enum EditState {
    case create
    case update(memo: Memo)
}

extension Container {
    @MainActor
    var mainViewModel: Factory<MainViewModel> {
        self { @MainActor in MainViewModel() }.cached
    }
}
