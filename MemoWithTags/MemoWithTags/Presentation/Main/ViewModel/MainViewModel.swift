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
    @ObservationIgnored @Injected(\.memoService) private var memoService: MemoService
    @ObservationIgnored @Injected(\.tagService) private var tagService: TagService
    @ObservationIgnored @Injected(\.userService) private var userService: UserService
    
    @Injected(\.appState) private var appState: AppState
    @Injected(\.navigation) private var navigation: Navigation
    @Injected(\.alert) private var alert: Alert
    
    var isLoading: Bool = false
    var currentPage: Int = 0 // 로드된 페이지 중 가장 높은 페이지 (최초 값: 0)
    var totalPages: Int = 1
    var scrollTarget: Int = -1 // scroll할 memoId. (-1는 default 값으로, -1이 되면 가장 아래로 scroll된다.)
    var recommendingMemoIds: [Int] = []
    var highlightingMemoIndex: Int = -1
    
    var memos: [Memo] {
        appState.memos
    }
    
    //MARK: - 메모 페이지 별로 가져오기
    func fetchMemos() async {
        guard !isLoading else { return }
        isLoading = true

        let nextPage = currentPage + 1
        
        guard nextPage <= totalPages else {
            isLoading = false
            return
        }
        
        let result = await memoService.searchMemos(content: nil, tagIds: nil, dateRange: nil, page: nextPage)
        
        switch result {
        case .success(let paginatedMemos):
            appState.memos.append(contentsOf: paginatedMemos.memos)
            currentPage = nextPage
            totalPages = paginatedMemos.totalPages
            
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 메모 생성
    func createMemo(content: String, tagIds: [Int], locked: Bool) async {
        isLoading = true
        
        let result = await memoService.createMemo(content: content, tagIds: tagIds, locked: locked)
        
        switch result {
        case .success(let memo):
            appState.memos.insert(memo, at: 0)
            
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 메모 수정
    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async {
        isLoading = true
        
        let result = await memoService.updateMemo(memoId: memoId, content: content, tagIds: tagIds, locked: locked)
        
        switch result {
        case .success(let memo):
            if let index = appState.memos.firstIndex(where: { $0.id == memo.id }) {
                appState.memos[index] = memo
            }
//            if let index = self.searchedMemos.firstIndex(where: { $0.id == memo.id }) {
//                self.searchedMemos[index] = memo
//            }
            
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - editor에서 submit 했을 때 작동
    func submit() async {
        let trimmedContent = editorContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }

        switch editorState {
        case .create:
            await createMemo(content: trimmedContent, tagIds: editorTagIds, locked: false)
            self.memos = []
            self.mainCurrentPage = 0
            self.mainTotalPages = 1
            await fetchMemos()

        case .update(let target):
            await updateMemo(memoId: target.id, content: trimmedContent, tagIds: editorTagIds, locked: target.locked)
        }

        // Reset the input fields
        editorState = .create
        editorContent = ""
        editorTagIds = []
        recommendingMemoIds = []
        highlightingMemoIndex = -1
        hideKeyboard()
    }
    
    //MARK: - 메모 삭제
    func deleteMemo(memoId: Int) async {
        isLoading = true
        
        let mainPrefetched = await prefetchMainMemo()
//        let searchPrefetched = await prefetchSearchMemo()
        
        let result = await memoService.deleteMemo(memoId: memoId)
        
        switch result {
        case .success:
            var beforeCount = appState.memos.count
            appState.memos.removeAll { $0.id == memoId }
            
            if beforeCount != appState.memos.count && mainPrefetched != nil {
                appState.memos.append(mainPrefetched!)
            }

//            beforeCount = searchedMemos.count
//            self.searchedMemos.removeAll { $0.id == memoId }
//            if beforeCount != searchedMemos.count && searchPrefetched != nil{
//                self.searchedMemos.append(searchPrefetched!)
//            }
            
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 삭제 시, 다음 페이지의 메모를 하나 미리 가져오기 위한 함수
    func prefetchMainMemo() async -> Memo? {
        guard currentPage + 1 <= totalPages else { return nil }
        
        let resultMain = await memoService.searchMemos(content: nil, tagIds: nil, dateRange: nil, page: currentPage + 1)
        
        switch resultMain {
        case .success(let paginatedMemos):
            return paginatedMemos.memos.first
            
        case .failure(let error):
            alert.alert(error: error)
            return nil
        }
    }
    
//    func prefetchSearchMemo() async -> Memo? {
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
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await tagService.fetchTag()
        
        switch result {
        case .success(let tags):
            appState.tags = tags
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 태그 생성
    func createTag(name: String, color: Color.TagColor) async {
        isLoading = true
        
        let result = await tagService.createTag(name: name, color: color)
        
        switch result {
        case .success(let tag):
            appState.tags.append(tag)
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 태그 수정
    func updateTag(tagId: Int, name: String, color: Color.TagColor) async {
        isLoading = true
        
        let result = await tagService.updateTag(tagId: tagId, name: name, color: color)
        
        switch result {
        case .success(let tag):
            if let index = appState.tags.firstIndex(where: { $0.id == tagId }) {
                appState.tags[index] = tag
            }
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 태그 삭제
    func deleteTag(tagId: Int) async {
        isLoading = true
        
        let result = await tagService.deleteTag(tagId: tagId)
        
        switch result {
        case .success:
            appState.tags.removeAll { $0.id == tagId }

            for index in appState.memos.indices {
                appState.memos[index].tagIds.removeAll { $0 == tagId }
            }
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 유저 정보 가져오는 함수
    func getUser() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await userService.getUser()
        
        switch result {
        case .success(let user):
            appState.user = user
            
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 초기화 함수
    func initialize() async {
        if appState.user == nil {
            await getUser()
        }
        if appState.tags.isEmpty {
            await fetchTags()
        }
        if appState.memos.isEmpty {
            currentPage = 0
            totalPages = 1
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
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //MARK: - 태그 추천 해주는 함수(editor에 들어간 것들 뺴고)
//    func recommendTags() -> [Tag] {
//        tags.filter { !editorTagIds.contains($0.id) }
//    }
    
    //MARK: - tag id --> tag 맵핑하는 함수
    func getTags(from tagIds: [Int]) -> [Tag] {
        return tagIds.compactMap { id in
            tags.first { $0.id == id }
        }
    }
}

extension Container {
    @MainActor
    var mainViewModel: Factory<MainViewModel> {
        self { @MainActor in MainViewModel() }.singleton
    }
}
