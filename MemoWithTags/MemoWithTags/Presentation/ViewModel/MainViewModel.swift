//
//  MainViewModel.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import Foundation
import SwiftUI
import RichTextKit

@MainActor
final class MainViewModel: BaseViewModel, ObservableObject {
    
    @Published var isLoading: Bool = false
    
    //mainPage 변수들
    @Published var memos: [Memo] = []
    @Published var tags: [Tag] = []
    @Published var mainCurrentPage: Int = 0
    @Published var mainTotalPages: Int = 1
    
    //searchPage 변수들
    @Published var searchBarText: String = ""
    @Published var searchBarSelectedTags: [Tag] = []
    @Published var searchedMemos: [Memo] = []
    @Published var searchedTags: [Tag] = []
    @Published var searchCurrentPage: Int = 0
    @Published var searchTotalPages: Int = 1
    
    // editor의 변수들 (축소, 확대 상태 모두)
    @Published var editorState: EditorState = .create
    @Published var editorContent = NSAttributedString(string: "")
    @Published var context = RichTextContext()
    @Published var editorTags: [Tag] = []
    enum EditorState: Equatable {
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
    
    // mainView에서 첫 검색을 할 때나, pagenation을 할 때 모두 사용된다.
    func fetchMemos() async {
        guard !isLoading else { return }
        
        isLoading = true
        mainCurrentPage += 1
        
        guard mainCurrentPage <= mainTotalPages else {
            isLoading = false
            mainCurrentPage -= 1
            return
        }
        
        let result = await useCases.fetchMemoUseCase.execute(content: nil, tagIds: nil, dateRange: nil, page: mainCurrentPage)
        
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
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    // searchView에서 첫 검색을 할 때나, pagenation을 할 때 모두 사용된다.
    func searchMemos(content: String? = nil, tagIds: [Int]? = nil, dateRange: ClosedRange<Date>? = nil) async {
        guard !isLoading else { return }
        
        isLoading = true
        searchCurrentPage += 1
        
        guard searchCurrentPage <= searchTotalPages else {
            isLoading = false
            searchCurrentPage -= 1
            return
        }
        
        let result = await useCases.fetchMemoUseCase.execute(content: content, tagIds: tagIds, dateRange: dateRange, page: self.searchCurrentPage)
        
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
            // SearchView에서 wait이 끝나고 searchMemo가 실행되는 와중에 새로운 Task가 생성되어서 Task가 사라지면 MemoError.unknown이 뜬다. 이것은 정상적인 결과이기 때문에 무시한다.
            if (error != MemoError.unknown) {
                appState.system.showAlert = true
                appState.system.errorMessage = error.localizedDescription()
            }
        }
        
        isLoading = false
    }
    
    func createMemo(content: String, tagIds: [Int], locked: Bool) async {
        isLoading = true
        
        let result = await useCases.createMemoUseCase.execute(content: content, tagIds: tagIds, locked: locked)
        
        switch result {
        case .success(let memo):
            var memoWithFilledTags = memo
            memoWithFilledTags.tags = getTags(from: memoWithFilledTags.tagIds)
            self.memos.insert(memoWithFilledTags, at: 0)
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    func updateMemo(memoId: Int, content: String, tagIds: [Int], locked: Bool) async {
        isLoading = true
        
        let result = await useCases.updateMemoUseCase.execute(memoId: memoId, content: content, tagIds: tagIds, locked: locked)
        switch result {
        case .success(let memo):
            var memoWithFilledTags = memo
            memoWithFilledTags.tags = getTags(from: memoWithFilledTags.tagIds)
            if let index = self.memos.firstIndex(where: { $0.id == memoId }) {
                self.memos[index] = memoWithFilledTags
            }
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    func deleteMemo(memoId: Int) async {
        isLoading = true
        
        let result = await useCases.deleteMemoUseCase.execute(memoId: memoId)
        switch result {
        case .success:
            self.memos.removeAll { $0.id == memoId }
            self.searchedMemos.removeAll { $0.id == memoId }
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    func fetchTags() async {
        isLoading = true
        
        let result = await useCases.fetchTagUseCase.execute()
        switch result {
        case .success(let fetchedTags):
            self.tags = fetchedTags
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    func createTag(name: String, color: Color.TagColor) async {
        isLoading = true
        
        let result = await useCases.createTagUseCase.execute(name: name, color: color)
        switch result {
        case .success(let tag):
            self.tags.append(tag)
//            self.editingMemoSelectedTags.append(tag)
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    func updateTag(tagId: Int, name: String, color: Color.TagColor) async {
        isLoading = true
        
        let result = await useCases.updateTagUseCase.execute(tagId: tagId, name: name, color: color)
        switch result {
        case .success(let tag):
            // Main과 Search의 tag 변경
            if let index = self.tags.firstIndex(where: { $0.id == tagId }) {
                self.tags[index] = tag
            }
            if let index = self.searchedTags.firstIndex(where: { $0.id == tagId }) {
                self.searchedTags[index] = tag
            }
            
            // Main과 Search의 tag 변경
            for index in memos.indices {
                if let tagIndex = memos[index].tags.firstIndex(where: { $0.id == tagId }) {
                    memos[index].tags[tagIndex] = tag
                }
            }
            // Main과 Search의 memo에 있는 tag 변경
            for index in searchedMemos.indices {
                if let tagIndex = searchedMemos[index].tags.firstIndex(where: { $0.id == tagId }) {
                    searchedMemos[index].tags[tagIndex] = tag
                }
            }
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    func deleteTag(tagId: Int) async {
        isLoading = true
        
        let result = await useCases.deleteTagUseCase.execute(tagId: tagId)
        switch result {
        case .success:
            // Main과 Search의 tag 삭제
            self.tags.removeAll { $0.id == tagId }
            self.searchedTags.removeAll { $0.id == tagId }
            
            // Main과 Search의 memo에 있는 tag 삭제
            for index in memos.indices {
                self.memos[index].tags.removeAll { $0.id == tagId }
            }
            for index in searchedMemos.indices {
                self.searchedMemos[index].tags.removeAll { $0.id == tagId }
            }
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    ///main view에서 onApear때 쓰는 함수
    func initMemo() async {
        if tags.isEmpty {
            await fetchTags()
        }
        if memos.isEmpty {
            await fetchMemos()
        }
    }
    
    ///settings view에서 유저정보 가져오는 함수
    func getUserInfo() async {
        isLoading = true
        
        let result = await useCases.getUserInfoUseCase.execute()
        
        switch result {
        case .success(let user):
            appState.user.userId = user.id
            appState.user.userName = user.nickname
            appState.user.userEmail = user.email
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    ///settings view에서 로그아웃하는 함수
    func logout() async {
        let result = await useCases.logoutUseCase.execute()
        
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
            appState.system.errorMessage = error.localizedDescription()
        }
    }
    
    ///태그 추천 해주는 함수: editor에 들어간 것들 뺴고
    func recommendTags() -> [Tag] {
        tags.filter { !editorTags.contains($0) }
    }
    
    ///editor에서 submit 했을 때 작동
    func submit() async {
        let trimmedContent = editorContent.string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }
        
        guard let html = editorContent.toHTML() else { return }
        let tagIds = editorTags.map { $0.id }
    
        switch editorState {
        case .create:
            await createMemo(content: html, tagIds: tagIds, locked: false)
            memos = []
            mainCurrentPage = 0
            await fetchMemos()

        case .update(let target):
            await updateMemo(memoId: target.id, content: html, tagIds: tagIds, locked: target.locked)
        }
        
        // Reset the input fields
        editorState = .create
        editorContent = .init(string: "")
        editorTags = []
        hideKeyboard()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// tag id --> tag 맵핑하는 함수
    private func getTags(from tagIDs: [Int]) -> [Tag] {
        return tags.filter { tagIDs.contains($0.id) }
    }
    
    func clearMain() {
        memos = []
        tags = []
        mainCurrentPage = 0
        mainTotalPages = 1
        
        editorState = .create
        editorContent = .init(string: "")
        editorTags = []
    }
    
    func clearSearch() {
        searchBarText = ""
        searchBarSelectedTags = []
        searchedMemos = []
        searchedTags = []
        searchCurrentPage = 0
        searchTotalPages = 1
    }
}

