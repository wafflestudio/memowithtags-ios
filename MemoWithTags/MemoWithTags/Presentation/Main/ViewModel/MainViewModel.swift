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
    var tags: [Tag] { appState.tags }
    
    private var mainCurrentPage: Int = 0
    private var mainTotalPages: Int = 1
    
    private var mainLoading: Bool = false
    
    var editContent: String = ""
    var editTagList: [TagID] = []
    var editState: EditState = .creating
    enum EditState {
        case creating
        case updating(memo: Memo)
    }
    
    //search
    var searchedMemos: [Memo] = []
    var searchedTags: [TagID] = []
    
    private var searchCurrentPage: Int = 0
    private var searchTotalPages: Int = 1
    
    //task
    private static var tempID: Int = -1
    var scrollTrigger: Bool = false
    var scrollTarget: Int = -1
//    var recommendingMemoIds: [Int] = []
//    var highlightingMemoIndex: Int = -1
    
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
        let tempID = MainViewModel.tempID
        let tempMemo = Memo(id: tempID,
                             content: content,
                             tagIds: tagIds,
                             locked: locked,
                             createdAt: Date(),
                             updatedAt: Date(),
                             state: .creating)
        MainViewModel.tempID -= 1
        memos.insert(tempMemo, at: 0)
        
        let result = await memoService.createMemo(content: content, tagIds: tagIds, locked: locked)
        
        switch result {
        case .success(let memo):
            let mainPrefetched = await prefetchMainMemo()
            
            if mainPrefetched != nil && memos.contains(mainPrefetched!) {
                memos.removeAll { $0.id == mainPrefetched!.id }
            }
            
            if let index = memos.firstIndex(where: { $0.id == tempID }) {
                memos[index] = memo
            }
            
        case .failure(let error):
            alert.alert(error: error)
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
            alert.alert(error: error)
        }
    }
    
    
    //MARK: - 메모 삭제
    func deleteMemo(memoId: Int) async {
        let mainPrefetched = await prefetchMainMemo()
//        let searchPrefetched = await prefetchSearchedMemo()
        
        let result = await memoService.deleteMemo(memoId: memoId)
        
        switch result {
        case .success:
            let beforeCount = memos.count
            memos.removeAll { $0.id == memoId }
            if beforeCount != memos.count && mainPrefetched != nil {
                memos.append(mainPrefetched!)
            }
 
//            beforeCount = searchedMemos.count
//            searchedMemos.removeAll { $0.id == memoId }
//            if beforeCount != searchedMemos.count && searchPrefetched != nil{
//                searchedMemos.append(searchPrefetched!)
//            }
            
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
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
//    
//    func prefetchSearchedMemo() async -> Memo? {
//        let content = searchBarText.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        guard !content.isEmpty || !searchBarSelectedTagIds.isEmpty else { return nil }
//        guard searchCurrentPage + 1 <= searchTotalPages else { return nil }
//        
//        let resultSearch = await useCases.memoService.searchMemos(content: content, tagIds: searchBarSelectedTagIds, dateRange: nil, page: searchCurrentPage + 1)
//        
//        switch resultSearch {
//        case .success(let paginatedMemos):
//            return paginatedMemos.memos.first
//        case .failure(let error):
//            appState.system.alert(error: error)
//            return nil
//        }
//    }
    
    // MARK: - 추천 메모 ID 가져오기
//    func recommendMemos() async {
//        self.recommendingMemoIds = []
//        self.highlightingMemoIndex = -1
//        if editorTagIds.isEmpty { return }
//        
//        guard !isLoading else { return }
//        
//        isLoading = true
//        
//        let result = await memoService.recommendMemos(content: self.editorContent, tagIds: self.editorTagIds)
//        
//        switch result {
//        case .success(let recommendedMemoIds):
//            var ids = recommendedMemoIds.memoIds
//            // .update 상태인 경우, 업데이트 대상 memo id는 recommendedMemoIds에서 제외
//            if case let .update(target) = editorState {
//                ids.removeAll { $0 == target.id }
//            }
//            self.recommendingMemoIds = ids
//        case .failure(let error):
//            alert.alert(error: error)
//        }
//        
//        isLoading = false
//    }
    
    //MARK: - 태그 전부 가져오기
    func fetchTags() async {
        let result = await tagService.fetchTag()
        
        switch result {
        case .success(let tags):
            appState.tags = tags
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
    //MARK: - 태그 생성
    func createTag(name: String, color: Color.TagColor) async {
        let result = await tagService.createTag(name: name, color: color)
        
        switch result {
        case .success(let tag):
            appState.tags.append(tag)
            
        case .failure(let error):
            alert.alert(error: error)
        }
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
            alert.alert(error: error)
        }
    }
    
    //MARK: - 새로운 검색어, 태그에 대한 검색 수행
    func search(text: String, tagIds: [Int]) async {
        searchedMemos = []
        searchedTags = []
        searchCurrentPage = 0
        searchTotalPages = 1
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedText.isEmpty || !tagIds.isEmpty {
            await searchMemos(content: trimmedText, tagIds: tagIds)
            
            searchedTags = appState.tags.filter { tag in
                tag.name.lowercased().contains(trimmedText.lowercased()) && !tagIds.contains(tag.id)
            }.map(\.id)
        }
    }
    
    //MARK: - 유저 정보 가져오는 함수
    func getUser() async {
        let result = await userService.getUser()
        
        switch result {
        case .success(let user):
            appState.user = user
            
        case .failure(let error):
            alert.alert(error: error)
        }
    }
    
    //MARK: - 초기화 함수
    func initialize() async {
        if appState.user == nil {
            await getUser()
        }
        if appState.tags.isEmpty {
            await fetchTags()
        }
        if memos.isEmpty {
            mainCurrentPage = 0
            mainTotalPages = 1
            await fetchMemos()
        }
    }
    
    //MARK: - editor에서 submit 했을 때 작동
    func submit() async {
//        let trimmedContent = editorContent.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedContent.isEmpty else { return }
//        
//        switch editorState {
//        case .create:
//            await createMemo(content: trimmedContent, tagIds: editorTagIds, locked: false)
//            self.memos = []
//            self.mainCurrentPage = 0
//            self.mainTotalPages = 1
//            await fetchMemos()
//            
//        case .update(let target):
//            await updateMemo(memoId: target.id, content: trimmedContent, tagIds: editorTagIds, locked: target.locked)
//        }
//        
//        // Reset the input fields
//        editorState = .create
//        editorContent = ""
//        editorTagIds = []
//        recommendingMemoIds = []
//        highlightingMemoIndex = -1
//        hideKeyboard()
    }
    
    func save() async {
//        let trimmedContent = editorContent.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedContent.isEmpty else { return }
//        
//        switch editorState {
//        case .update(let target):
//            await updateMemo(memoId: target.id, content: trimmedContent, tagIds: editorTagIds, locked: target.locked)
//        default:
//            break
//        }
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

extension Container {
    @MainActor
    var mainViewModel: Factory<MainViewModel> {
        self { @MainActor in MainViewModel() }.cached
    }
}
