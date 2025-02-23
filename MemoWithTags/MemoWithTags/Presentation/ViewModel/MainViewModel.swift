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
    
    // mainPage 변수들
    @Published var memos: [Memo] = []
    @Published var tags: [Tag] = []
    @Published var mainCurrentPage: Int = 0
    @Published var mainTotalPages: Int = 1
    
    // searchPage 변수들
    @Published var searchBarText: String = ""
    @Published var searchBarSelectedTags: [Tag] = []
    @Published var searchedMemos: [Memo] = []
    @Published var searchedTags: [Tag] = []
    @Published var searchCurrentPage: Int = 0
    @Published var searchTotalPages: Int = 1
    
    // editor의 변수들 (축소, 확대 상태 모두)
    @Published var editorState: EditorState = .create
    @Published var editorContent: String = ""
    @Published var editorTags: [Tag] = []
    enum EditorState {
        case create
        case update(target: Memo)
    }
    
    // 메모 정렬과 관련된 변수
    @Published var sortMemo: Sort = .byCreate
    @Published var sortSearch: Sort = .byCreate
    enum Sort {
        case byCreate
        case byUpdate
    }
    
    // MARK: - 메모 목록 불러오기 (메인 화면, 페이지네이션)
    func fetchMemos() async {
        guard !isLoading else { return }
        
        isLoading = true
        mainCurrentPage += 1
        
        // 더 이상 가져올 페이지가 없으면 종료
        guard mainCurrentPage <= mainTotalPages else {
            isLoading = false
            mainCurrentPage -= 1
            return
        }
        
        // 변경된 부분: useCases.memoService.fetchMemo(...)
        let result = await useCases.memoService.fetchMemo(
            content: nil,
            tagIds: nil,
            dateRange: nil,
            page: mainCurrentPage
        )
        
        switch result {
        case .success(let paginatedMemos):
            let updatedMemos = paginatedMemos.memos.map { memo -> Memo in
                var updatedMemo = memo
                updatedMemo.tags = getTags(from: updatedMemo.tagIds)
                return updatedMemo
            }
            
            self.memos.append(contentsOf: updatedMemos)
            self.mainTotalPages = paginatedMemos.totalPages
            
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 메모 검색 (검색 화면, 페이지네이션)
    func searchMemos(content: String? = nil, tagIds: [Int]? = nil, dateRange: ClosedRange<Date>? = nil) async {
        guard !isLoading else { return }
        
        isLoading = true
        searchCurrentPage += 1
        
        // 더 이상 가져올 페이지가 없으면 종료
        guard searchCurrentPage <= searchTotalPages else {
            isLoading = false
            searchCurrentPage -= 1
            return
        }
        
        // 변경된 부분: useCases.memoService.fetchMemo(...)
        let result = await useCases.memoService.fetchMemo(
            content: content,
            tagIds: tagIds,
            dateRange: dateRange,
            page: searchCurrentPage
        )
        
        switch result {
        case .success(let paginatedMemos):
            let updatedMemos = paginatedMemos.memos.map { memo -> Memo in
                var updatedMemo = memo
                updatedMemo.tags = getTags(from: updatedMemo.tagIds)
                return updatedMemo
            }
            
            self.searchedMemos.append(contentsOf: updatedMemos)
            self.searchTotalPages = paginatedMemos.totalPages
            
        case .failure(let error):
            // Task가 도중에 취소된 경우 .unknown 에러 발생 가능 → 무시 처리를 하던 로직
            if error != MemoError.unknown {
                appState.system.showAlert = true
                appState.system.errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    // MARK: - 메모 생성
    func createMemo(content: String, tagIds: [Int], locked: Bool) async {
        isLoading = true
        
        // 변경된 부분: useCases.memoService.createMemo(...)
        let result = await useCases.memoService.createMemo(content: content, tagIds: tagIds, locked: locked)
        
        switch result {
        case .success(let memo):
            var memoWithFilledTags = memo
            memoWithFilledTags.tags = getTags(from: memoWithFilledTags.tagIds)
            self.memos.insert(memoWithFilledTags, at: 0)
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 메모 수정
    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async {
        isLoading = true
        
        // 변경된 부분: useCases.memoService.updateMemo(...)
        let result = await useCases.memoService.updateMemo(
            memoId: memoId,
            content: content,
            tagIds: tagIds,
            locked: locked
        )
        
        switch result {
        case .success(let memo):
            var memoWithFilledTags = memo
            memoWithFilledTags.tags = getTags(from: memoWithFilledTags.tagIds)
            
            if let index = self.memos.firstIndex(where: { $0.id == memoId }) {
                self.memos[index] = memoWithFilledTags
            }
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 메모 삭제
    func deleteMemo(memoId: Int) async {
        isLoading = true
        
        // 변경된 부분: useCases.memoService.deleteMemo(...)
        let result = await useCases.memoService.deleteMemo(memoId: memoId)
        
        switch result {
        case .success:
            self.memos.removeAll { $0.id == memoId }
            self.searchedMemos.removeAll { $0.id == memoId }
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 태그 목록 가져오기
    func fetchTags() async {
        isLoading = true
        
        // 변경된 부분: useCases.tagService.fetchTag()
        let result = await useCases.tagService.fetchTag()
        
        switch result {
        case .success(let fetchedTags):
            self.tags = fetchedTags
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 태그 생성
    func createTag(name: String, color: Color.TagColor) async {
        isLoading = true
        
        // 변경된 부분: useCases.tagService.createTag(...)
        let result = await useCases.tagService.createTag(name: name, color: color)
        
        switch result {
        case .success(let tag):
            self.tags.append(tag)
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 태그 수정
    func updateTag(tagId: Int, name: String, color: Color.TagColor) async {
        isLoading = true
        
        // 변경된 부분: useCases.tagService.updateTag(...)
        let result = await useCases.tagService.updateTag(
            tagId: tagId,
            name: name,
            color: color
        )
        
        switch result {
        case .success(let tag):
            // 태그 배열(tags, searchedTags)와 메모 내의 태그도 변경
            if let index = self.tags.firstIndex(where: { $0.id == tagId }) {
                self.tags[index] = tag
            }
            if let index = self.searchedTags.firstIndex(where: { $0.id == tagId }) {
                self.searchedTags[index] = tag
            }
            for index in memos.indices {
                if let tagIndex = memos[index].tags.firstIndex(where: { $0.id == tagId }) {
                    memos[index].tags[tagIndex] = tag
                }
            }
            for index in searchedMemos.indices {
                if let tagIndex = searchedMemos[index].tags.firstIndex(where: { $0.id == tagId }) {
                    searchedMemos[index].tags[tagIndex] = tag
                }
            }
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 태그 삭제
    func deleteTag(tagId: Int) async {
        isLoading = true
        
        // 변경된 부분: useCases.tagService.deleteTag(...)
        let result = await useCases.tagService.deleteTag(tagId: tagId)
        
        switch result {
        case .success:
            self.tags.removeAll { $0.id == tagId }
            self.searchedTags.removeAll { $0.id == tagId }
            
            for index in memos.indices {
                self.memos[index].tags.removeAll { $0.id == tagId }
            }
            for index in searchedMemos.indices {
                self.searchedMemos[index].tags.removeAll { $0.id == tagId }
            }
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - mainView onAppear 시 호출
    func initMemo() async {
        if tags.isEmpty {
            await fetchTags()
        }
        if memos.isEmpty {
            await fetchMemos()
        }
    }
    
    // MARK: - 설정 화면에서 유저 정보 가져오기
    func getUserInfo() async {
        isLoading = true
        
        // 변경된 부분: useCases.userService.getUser()
        let result = await useCases.userService.getUser()
        
        switch result {
        case .success(let user):
            appState.user.userId = user.id
            appState.user.userName = user.nickname
            appState.user.userEmail = user.email
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 로그아웃
    func logout() async {
        // 변경된 부분: useCases.authService.logout()
        let result = await useCases.authService.logout()
        
        switch result {
        case .success:
            clearMain()
            clearSearch()
            
            appState.user.isLoggedIn = false
            appState.user.userId = nil
            appState.user.userName = nil
            appState.user.userEmail = nil
            
            appState.navigation.reset()
            appState.navigation.push(to: .root)
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - 에디터에서 태그 추천 (현재 에디터에 없는 태그만 추려냄)
    func recommendTags() -> [Tag] {
        tags.filter { !editorTags.contains($0) }
    }
    
    // MARK: - 에디터에서 제출 액션
    func submit() async {
        let trimmedContent = editorContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }
        
        let tagIds = editorTags.map { $0.id }
        
        switch editorState {
        case .create:
            await createMemo(content: trimmedContent, tagIds: tagIds, locked: false)
            // 새 메모 작성 후 다시 첫 페이지부터 불러옴
            memos = []
            mainCurrentPage = 0
            await fetchMemos()
            
        case .update(let target):
            await updateMemo(memoId: target.id,
                             content: trimmedContent,
                             tagIds: tagIds,
                             locked: target.locked)
        }
        
        // 에디터 상태 및 입력값 초기화
        editorState = .create
        editorContent = ""
        editorTags = []
        hideKeyboard()
    }
    
    // MARK: - 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
    
    // MARK: - tagId 배열을 통해 해당 태그 객체들을 매핑
    private func getTags(from tagIDs: [Int]) -> [Tag] {
        return tags.filter { tagIDs.contains($0.id) }
    }
    
    // MARK: - 메인 페이지 상태 초기화
    func clearMain() {
        memos = []
        tags = []
        mainCurrentPage = 0
        mainTotalPages = 1
        
        editorState = .create
        editorContent = ""
        editorTags = []
    }
    
    // MARK: - 검색 페이지 상태 초기화
    func clearSearch() {
        searchBarText = ""
        searchBarSelectedTags = []
        searchedMemos = []
        searchedTags = []
        searchCurrentPage = 0
        searchTotalPages = 1
    }
}

