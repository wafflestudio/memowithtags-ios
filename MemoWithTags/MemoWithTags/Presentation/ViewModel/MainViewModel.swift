//
//  MainViewModel.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/30/25.
//

import Foundation
import SwiftUI

@MainActor
final class MainViewModel: BaseViewModel, ObservableObject {
    
    @Published var isLoading: Bool = false
    
    //MARK: - mainPage 변수들
    @Published var memos: [Memo] = []
    @Published var tags: [Tag] = []
    @Published var mainCurrentPage: Int = 0 // 로드된 페이지 중 가장 높은 페이지 (최초 값: 0)
    @Published var mainTotalPages: Int = 1
    @Published var scrollTarget: Int = -1 // scroll할 memoId. (-1는 default 값으로, -1이 되면 가장 아래로 scroll된다.)
    
    //MARK: - searchPage 변수들
    @Published var searchBarText: String = ""
    @Published var searchBarSelectedTagIds: [Int] = []
    @Published var searchedMemos: [Memo] = []
    @Published var searchedTagIds: [Int] = []
    @Published var searchCurrentPage: Int = 0
    @Published var searchTotalPages: Int = 1
    
    //MARK: - editor의 변수들 (축소, 확대 상태 모두)
    @Published var editorState: EditorState = .create
    @Published var editorContent: String = ""
    @Published var editorTagIds: [Int] = []
    @Published var recommendingMemoIds: [Int] = []
    @Published var highlightingMemoIndex: Int = -1
    enum EditorState {
        case create
        case update(target: Memo)
    }
    
    //MARK: - 메모 정렬과 관련된 변수
    @Published var sortMemo: Sort = .byCreate
    @Published var sortSearch: Sort = .byCreate
    enum Sort {
        case byCreate
        case byUpdate
    }
    
    //MARK: - 메모 페이지 별로 가져오기 (다음/이전 방향 모두 처리)
    func fetchMemos() async {
        guard !isLoading else { return }
        isLoading = true
        
        // 다음 페이지: 이미 로드된 최고 페이지보다 1 증가한 페이지
        let nextPage = mainCurrentPage + 1
        
        guard nextPage <= mainTotalPages else {
            isLoading = false
            return
        }
        
        let result = await useCases.memoService.searchMemos(content: nil, tagIds: nil, dateRange: nil, page: nextPage)
        switch result {
        case .success(let paginatedMemos):
            // 다음 페이지의 메모는 기존 배열 뒤에 추가
            self.memos.append(contentsOf: paginatedMemos.memos)
            self.mainTotalPages = paginatedMemos.totalPages
            self.mainCurrentPage = nextPage
            
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 검색된 메모 페이지별로 가져오기
    func searchMemos(content: String? = nil, tagIds: [Int]? = nil, dateRange: ClosedRange<Date>? = nil) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        searchCurrentPage += 1
        
        guard searchCurrentPage <= searchTotalPages else {
            isLoading = false
            searchCurrentPage -= 1
            return
        }
        
        let result = await useCases.memoService.searchMemos(content: content, tagIds: tagIds, dateRange: dateRange, page: searchCurrentPage)
        
        switch result {
        case .success(let paginatedMemos):
            self.searchedMemos.append(contentsOf: paginatedMemos.memos)
            self.searchTotalPages = paginatedMemos.totalPages
            
        case .failure(let error):
            // SearchView에서 wait이 끝나고 searchMemo가 실행되는 와중에 새로운 Task가 생성되어서 Task가 사라지면 MemoError.unknown이 뜬다. 이것은 정상적인 결과이기 때문에 무시한다.
            if (error != MemoError.unknown) {
                appState.system.alert(error: error)
            }
        }
        
        isLoading = false
    }
    
    //MARK: - 메모 생성
    func createMemo(content: String, tagIds: [Int], locked: Bool) async {
        isLoading = true
        
        let result = await useCases.memoService.createMemo(content: content, tagIds: tagIds, locked: locked)
        
        switch result {
        case .success(let memo):
            print(tagIds)
            print(memo.tagIds)
            self.memos.insert(memo, at: 0)
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 메모 수정
    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async {
        isLoading = true
        
        let result = await useCases.memoService.updateMemo(memoId: memoId, content: content, tagIds: tagIds, locked: locked)
        
        switch result {
        case .success(let memo):
            print(tagIds)
            print(memo.tagIds)
            if let index = self.memos.firstIndex(where: { $0.id == memo.id }) {
                self.memos[index] = memo
            }
            if let index = self.searchedMemos.firstIndex(where: { $0.id == memo.id }) {
                self.searchedMemos[index] = memo
            }
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 메모 삭제
    func deleteMemo(memoId: Int) async {
        isLoading = true
        
        let result = await useCases.memoService.deleteMemo(memoId: memoId)
        
        switch result {
        case .success:
            self.memos.removeAll { $0.id == memoId }
            self.searchedMemos.removeAll { $0.id == memoId }
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    // MARK: - 추천 메모 ID 가져오기
    func recommendMemos() async {
        self.recommendingMemoIds = []
        self.highlightingMemoIndex = -1
        if editorTagIds.isEmpty { return }
        
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await useCases.memoService.recommendMemos(content: self.editorContent, tagIds: self.editorTagIds)
        switch result {
        case .success(let recommendedMemoIds):
            var ids = recommendedMemoIds.memoIds
            // .update 상태인 경우, 업데이트 대상 memo id는 recommendedMemoIds에서 제외
            if case let .update(target) = editorState {
                ids.removeAll { $0 == target.id }
            }
            self.recommendingMemoIds = ids
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    // MARK: - 선택된 memoId 기반 주변 메모 가져오기
    // memoId가 속한 page만 가져오는 로직. 아래로 scroll할 때 끊기는 현상이 있어서 포기한 개발 방향이다.
    /*
    func fetchMemosByMemoId() async {
        if self.highlightingMemoIndex == -1 {
            self.memos = []
            self.lowestLoadedPage = 0
            self.highestLoadedPage = 0
            await self.fetchMemos(direction: .next)
            return
        }
        
        if self.highlightingMemoIndex >= self.recommendingMemoIds.count {
            print("highlightingMemoIndex out of bound")
            return
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await useCases.memoService.fetchMemosByMemoId(memoId: self.recommendingMemoIds[self.highlightingMemoIndex])
        switch result {
        case .success(let paginatedMemos):
            self.memos = paginatedMemos.memos
            self.lowestLoadedPage = paginatedMemos.currentPage
            self.highestLoadedPage = paginatedMemos.currentPage
            self.mainTotalPages = paginatedMemos.totalPages
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
     */
    
    //MARK: - 태그 전부 가져오기
    func fetchTags() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await useCases.tagService.fetchTag()
        
        switch result {
        case .success(let tags):
            self.tags = tags
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 태그 생성
    func createTag(name: String, color: Color.TagColor) async {
        isLoading = true
        
        let result = await useCases.tagService.createTag(name: name, color: color)
        
        switch result {
        case .success(let tag):
            self.tags.append(tag)
            self.editorTagIds.append(tag.id)
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 태그 수정
    func updateTag(tagId: Int, name: String, color: Color.TagColor) async {
        isLoading = true
        
        let result = await useCases.tagService.updateTag(tagId: tagId, name: name, color: color)
        
        switch result {
        case .success(let tag):
            if let index = self.tags.firstIndex(where: { $0.id == tagId }) {
                self.tags[index] = tag
            }
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 태그 삭제
    func deleteTag(tagId: Int) async {
        isLoading = true
        
        let result = await useCases.tagService.deleteTag(tagId: tagId)
        
        switch result {
        case .success:
            self.tags.removeAll { $0.id == tagId }
            // Main과 Search의 memo에 있는 tag 삭제
            for index in memos.indices {
                self.memos[index].tagIds.removeAll { $0 == tagId }
            }
            for index in searchedMemos.indices {
                self.searchedMemos[index].tagIds.removeAll { $0 == tagId }
            }
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - main view에서 onAppear때 쓰는 함수
    func initMemo() async {
        if tags.isEmpty {
            await fetchTags()
        }
        if memos.isEmpty {
            await fetchMemos()
        }
    }
    
    //MARK: - settings view에서 유저정보 가져오는 함수
    func getUserInfo() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await useCases.userService.getUser()
        
        switch result {
        case .success(let user):
            appState.user.userId = user.id
            appState.user.userName = user.nickname
            appState.user.userNumber = user.userNumber
            appState.user.userEmail = user.email
            appState.user.isSocial = user.isSocial
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - settings view에서 로그아웃하는 함수
    func logout() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await useCases.authService.logout()
        
        switch result {
        case .success:
            clearMain()
            clearSearch()
            clearEditor()
            
            appState.user.isLoggedIn = false
            appState.user.userId = nil
            appState.user.userName = nil
            appState.user.userEmail = nil
            
            appState.navigation.reset()
            appState.navigation.push(to: .root)
        case .failure(let error):
            appState.system.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - settings view에서 회원탈퇴하는 함수
    func withdrawal(email: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await useCases.userService.withdrawal(email: email)
        
        switch result {
        case .success:
            clearMain()
            clearSearch()
            clearEditor()
            
            appState.user.isLoggedIn = false
            appState.user.userId = nil
            appState.user.userName = nil
            appState.user.userEmail = nil
            
            appState.navigation.reset()
            appState.navigation.push(to: .root)
        case .failure(let error):
            appState.system.alert(error: error)
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
    
    //MARK: - 새로운 검색어, 태그에 대한 검색 수행
    func search() async {
        // 이전 검색 결과를 모두 리셋
        searchedMemos = []
        searchedTagIds = []
        searchCurrentPage = 0
        searchTotalPages = 1
        
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
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //MARK: - 태그 추천 해주는 함수(editor에 들어간 것들 뺴고)
    func recommendTags() -> [Tag] {
        tags.filter { !editorTagIds.contains($0.id) }
    }
    
    //MARK: - tag id --> tag 맵핑하는 함수
    func getTags(from tagIds: [Int]) -> [Tag] {
        return tagIds.compactMap { id in
            tags.first { $0.id == id }
        }
    }
    
    //MARK: - clear 함수들
    func clearMain() {
        memos = []
        tags = []
        mainCurrentPage = 0
        mainTotalPages = 1
    }
    
    func clearSearch() {
        searchBarText = ""
        searchBarSelectedTagIds = []
        searchedMemos = []
        searchedTagIds = []
        searchCurrentPage = 0
        searchTotalPages = 1
    }
    
    func clearEditor() {
        editorState = .create
        editorContent = ""
        editorTagIds = []
        recommendingMemoIds = []
        highlightingMemoIndex = -1
    }
}
