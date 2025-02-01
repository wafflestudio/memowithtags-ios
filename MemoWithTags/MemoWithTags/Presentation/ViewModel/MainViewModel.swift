//
//  MainViewModel.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/5/25.
//

import Foundation
import SwiftUI
import Accelerate

@MainActor
final class MainViewModel: BaseViewModel, ObservableObject {
    
    @Published var isLoading: Bool = false
    
    // 여기 있는 모든 리스트들은 정렬되지 않은 리스트다.
    // 단, recommendingMemos, recommendingTags, searchedMemos, searchedTag는 "관련성 기준"으로 정렬되어있다.
    
    // MARK: - Main Page Variables
    @Published var memos: [Memo] = []
    @Published var tags: [Tag] = []
    @Published var recommendingMemos: [Memo] = []
    @Published var recommendingTags: [Tag] = []
    // 참고: 사용자가 태그 검색 창에 검색을 한다고 recommendingTags는 변하지 않는다.
    // tagRecommendation에 recommendingTags가 그대로 보이는 것이 아니라, editor에 있는 tag를 제외하고 검색어와 안 맞는 tag를 제외하고 Create Tag를 하는 등 추가적인 과정이 있다.
    
    // MARK: - Search Page Variables
    @Published var searchBarText: String = ""
    @Published var searchBarSelectedTags: [Tag] = []
    @Published var searchedMemos: [Memo] = []
    @Published var searchedTags: [Tag] = []
    
    // MARK: - Editor Variables (Both Collapsed and Expanded States)
    @Published var editorState: EditorState = .create
    @Published var editorContent: String = ""
    @Published var editorTagSearchBarText: String = ""
    @Published var editorTags: [Tag] = []
    
    enum EditorState: Equatable {
        case create
        case update(target: Memo)
    }
    
    // MARK: - Memo Sorting Variables
    @Published var sortMemo: Sort = .byCreate
    
    enum Sort {
        case byCreate
        case byUpdate
    }
    
    // MARK: - Memo Scroll Target in MainView
    
    /// scrollTaget이 0이면 아무 것도 강조되지 않는다.
    /// 1부터 recommendedTags.count까지 있으면 그것 안에서 scroll이 되면서 강조된다.
    /// AI Recommend에서 사용한다.
    @Published var scrollTarget: Int = 0
    /// 기본적으로는 nil이다.
    /// searchView에서 넘어올 때 사용한다.
    @Published var scrollSingleTarget: UUID? = nil
    
    // MARK: - Load and Save Opeartions between Filesystem
    
    func loadMemosAndTagsFromFileSystem() async {
        let result = await useCases.loadMemosAndTagsUseCase.execute()
        
        switch result {
        case .success(let data):
            print("Successfully loaded Memos and Tags.")
            self.memos = data.memos
            self.tags = data.tags
        case .failure(let error):
            switch error {
            case .fileNotFound:
                // 파일이 존재하지 않는 경우, 빈 배열로 초기화하고 파일 생성
                print("Files not found. Initializing memos.json and tags.json.")
                self.memos = []
                self.tags = []
                await saveMemosAndTagsToFileSystem()
            default:
                appState.system.showAlert = true
                appState.system.errorMessage = error.errorDescription ?? error.localizedDescription
            }
        }
    }
    
    func saveMemosAndTagsToFileSystem() async {
        let result = await useCases.saveMemosAndTagsUseCase.execute(memos: self.memos, tags: self.tags)
        
        switch result {
        case .success():
            print("Memos and Tags successfully saved to filesystem.")
        case .failure(let error):
            print("Failed to save Memos and Tags.")
            appState.system.showAlert = true
            appState.system.errorMessage = error.errorDescription ?? error.localizedDescription
        }
    }
    
    // MARK: - CRUD Operations for Memos
    
    /// 메모를 생성할 때 임베딩 벡터를 생성하고, 관련 태그의 임베딩 벡터를 업데이트합니다.
    func createMemo(content: String, tagIds: [UUID], locked: Bool) async {
        isLoading = true
        
        do {
            let newId = UUID()
            
            let embeddingVector = try await createEmbeddingVectorWithAI(text: content)
            
            let currentDate = Date()
            
            let result = await useCases.createMemoUseCase.execute(
                id: newId,
                content: content,
                tagIds: tagIds,
                locked: locked,
                embeddingVector: embeddingVector,
                createdAt: currentDate,
                updatedAt: currentDate
            )
            
            switch result {
            case .success(let memo):
                self.memos.append(memo)
                
                // 관련 태그의 임베딩 벡터 업데이트
                await updateAssociatedTagsEmbedding(for: memo)
                
                await saveMemosAndTagsToFileSystem()
                
            case .failure(let error):
                if error == .unsureUser {
                    appState.system.showSessionAlert = true
                } else {
                    appState.system.showAlert = true
                }
                
                appState.system.errorMessage = error.localizedDescription()
            }
        } catch {
            appState.system.showAlert = true
            appState.system.errorMessage = "메모 생성 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// 메모를 업데이트할 때 임베딩 벡터를 생성하고, 관련 태그의 임베딩 벡터를 업데이트합니다.
    func updateMemo(id: UUID, content: String, tagIds: [UUID], locked: Bool) async {
        isLoading = true
        
        do {
            let updatingMemoIndex = self.memos.firstIndex(where: { $0.id == id })!
            
            let embeddingVector = try await createEmbeddingVectorWithAI(text: content)
            
            let currentDate = Date()
            
            let result = await useCases.updateMemoUseCase.execute(
                id: id,
                content: content,
                tagIds: tagIds,
                locked: locked,
                embeddingVector: embeddingVector,
                createdAt: self.memos[updatingMemoIndex].createdAt,
                updatedAt: currentDate
            )
            
            switch result {
            case .success(let memo):
                self.memos[updatingMemoIndex] = memo
                await saveMemosAndTagsToFileSystem()
            case .failure(let error):
                if error == .unsureUser {
                    appState.system.showSessionAlert = true
                } else {
                    appState.system.showAlert = true
                }
                appState.system.errorMessage = error.localizedDescription()
            }
        } catch {
            appState.system.showAlert = true
            appState.system.errorMessage = "메모 업데이트 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// 메모를 삭제합니다.
    func deleteMemo(id: UUID) async {
        isLoading = true
        
        let result = await useCases.deleteMemoUseCase.execute(id: id)
        switch result {
        case .success:
            self.memos.removeAll { $0.id == id }
            self.searchedMemos.removeAll { $0.id == id }
            await saveMemosAndTagsToFileSystem()
        case .failure(let error):
            if error == .unsureUser {
                appState.system.showSessionAlert = true
            } else {
                appState.system.showAlert = true
            }
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    // MARK: - CRUD Operations for Tags
    
    /// 태그를 생성할 때 임베딩 벡터를 생성합니다.
    func createTag(name: String, color: Color.TagColor) async {
        isLoading = true
        
        do {
            let newId = UUID()
            
            let embeddingVector = try await createEmbeddingVectorWithAI(text: name)
            
            let currentDate = Date()
            
            let result = await useCases.createTagUseCase.execute(
                id: newId,
                name: name,
                color: color,
                embeddingVector: embeddingVector,
                createdAt: currentDate,
                updatedAt: currentDate
            )
            
            switch result {
            case .success(let tag):
                self.tags.append(tag)
                // 현재 수정하고 있는 메모에 tag를 추가해야 한다.
                await saveMemosAndTagsToFileSystem()
                
                recommendMemosAndTags()
            case .failure(let error):
                if error == .unsureUser {
                    appState.system.showSessionAlert = true
                } else {
                    appState.system.showAlert = true
                }
                appState.system.errorMessage = error.localizedDescription()
            }
        } catch {
            appState.system.showAlert = true
            appState.system.errorMessage = "태그 생성 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// 태그를 업데이트할 때 임베딩 벡터를 생성합니다.
    func updateTag(id: UUID, name: String, color: Color.TagColor) async {
        isLoading = true
        
        do {
            let updatingTagIndex = self.tags.firstIndex(where: { $0.id == id })!
            
            let embeddingVector = try await createEmbeddingVectorWithAI(text: name)
            
            let currentDate = Date()
            
            let result = await useCases.updateTagUseCase.execute(
                id: id,
                name: name,
                color: color,
                embeddingVector: embeddingVector,
                createdAt: self.tags[updatingTagIndex].createdAt,
                updatedAt: currentDate
            )
            
            switch result {
            case .success(let tag):
                self.tags[updatingTagIndex] = tag
                await saveMemosAndTagsToFileSystem()
                
                recommendMemosAndTags()
            case .failure(let error):
                if error == .unsureUser {
                    appState.system.showSessionAlert = true
                } else {
                    appState.system.showAlert = true
                }
                appState.system.errorMessage = error.localizedDescription()
            }
        } catch {
            appState.system.showAlert = true
            appState.system.errorMessage = "태그 업데이트 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// 태그를 삭제합니다.
    func deleteTag(id: UUID) async {
        isLoading = true
        
        let result = await useCases.deleteTagUseCase.execute(id: id)
        switch result {
        case .success:
            // Main과 Search의 태그 삭제
            self.tags.removeAll { $0.id == id }
            self.searchedTags.removeAll { $0.id == id }
            
            // Main과 Search의 메모에서 해당 태그 삭제
            for index in memos.indices {
                self.memos[index].tagIds.removeAll { $0 == id }
            }
            for index in searchedMemos.indices {
                self.searchedMemos[index].tagIds.removeAll { $0 == id }
            }
            await saveMemosAndTagsToFileSystem()
            
            recommendMemosAndTags()
        case .failure(let error):
            if error == .unsureUser {
                appState.system.showSessionAlert = true
            } else {
                appState.system.showAlert = true
            }
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    // MARK: - Initialization and User Info
    
    /// Main View가 나타날 때 호출되는 초기화 함수
    func initMainViewModel() async {
        await getUserInfo()
        guard let userId = appState.user.userId else { return }
        useCases.userChangedUseCase.execute(userId: userId)
        if memos.isEmpty || tags.isEmpty {
            await loadMemosAndTagsFromFileSystem()
        }
    }
    
    /// Settings View에서 유저 정보를 가져오는 함수
    func getUserInfo() async {
        isLoading = true
        
        let result = await useCases.getUserInfoUseCase.execute()
        
        switch result {
        case .success(let user):
            appState.user.userId = user.id
            appState.user.userNumber = user.userNumber
            appState.user.userName = user.nickname
            appState.user.userEmail = user.email
        case .failure(let error):
            if error == .userNotFound {
                appState.system.showSessionAlert = true
            } else {
                appState.system.showAlert = true
            }
            appState.system.errorMessage = error.localizedDescription()
        }
        
        isLoading = false
    }
    
    /// Settings View에서 로그아웃하는 함수
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
    
    /// Editor에서 Submit 했을 때 작동
    func submit() async {
        hideKeyboard()
        
        let trimmedContent = editorContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }
        let tagIds = editorTags.map { $0.id }
        
        switch editorState {
        case .create:
            await createMemo(content: trimmedContent, tagIds: tagIds, locked: false)

        case .update(let target):
            await updateMemo(id: target.id, content: trimmedContent, tagIds: tagIds, locked: target.locked)
        }
        
        // 입력 필드 초기화
        editorState = .create
        editorContent = ""
        editorTags = []
    }
    
    func withdrawal(email: String) async {
        let result = await useCases.withdrawalUseCase.execute(email: email)
        
        switch result {
        case .success:
            appState.navigation.reset()
            appState.navigation.push(to: .root)
        case .failure(let error):
            if error == .userNotFound {
                appState.system.showSessionAlert = true
            } else {
                appState.system.showAlert = true
            }
            appState.system.errorMessage = error.localizedDescription()
        }
    }
    
    // MARK: - Helper Functions
    
    /// 키보드를 숨깁니다.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// 메인 관련 데이터를 초기화합니다.
    func clearMain() {
        memos = []
        tags = []
        
        editorState = .create
        editorContent = ""
        editorTags = []
    }
    
    /// 검색 관련 데이터를 초기화합니다.
    func clearSearch() {
        searchBarText = ""
        searchBarSelectedTags = []
        searchedMemos = []
        searchedTags = []
    }
    
    func mapTags(from tagIds: [UUID]) -> [Tag] {
        return tags.filter { tagIds.contains($0.id) }
    }
    
    func getSortedMemos() -> [Memo] {
        switch sortMemo {
        case .byCreate:
            return memos.sorted { (memo1: Memo, memo2: Memo) -> Bool in
                return memo1.createdAt < memo2.createdAt
            }
        case .byUpdate:
            return memos.sorted { (memo1: Memo, memo2: Memo) -> Bool in
                return memo1.updatedAt < memo2.updatedAt
            }
        }
    }
    
    func getSortedRecommendedMemos() -> [Memo] {
        switch sortMemo {
        case .byCreate:
            return recommendingMemos.sorted { (memo1: Memo, memo2: Memo) -> Bool in
                return memo1.createdAt > memo2.createdAt
            }
        case .byUpdate:
            return recommendingMemos.sorted { (memo1: Memo, memo2: Memo) -> Bool in
                return memo1.updatedAt > memo2.updatedAt
            }
        }
    }
    
    // MARK: - Helper Functions With AI
    
    /// 텍스트로부터 임베딩 벡터를 생성합니다.
    func createEmbeddingVectorWithAI(text: String) async throws -> [Float] {
        let embeddings = try AIModel.shared.encode(texts: [text])
        return embeddings.first ?? []
    }
    
    /// 메모 임베딩 벡터를 사용하여 태그 임베딩 벡터를 업데이트합니다.
    func updateTagEmbeddingWithAI(memoEmbeddingVector: [Float], tagEmbeddingVector: [Float]) -> [Float] {
        // 태그 임베딩을 메모 임베딩 쪽으로 1/100만큼 이동
        let alpha: Float = 0.01
        let updatedEmbedding = zip(tagEmbeddingVector, memoEmbeddingVector).map { $0 + alpha * $1 }
        return updatedEmbedding
    }
    
    /// 특정 메모에 속하는 모든 태그의 임베딩 벡터를 업데이트합니다.
    /// CreateMemo할 때만 호출한다.
    private func updateAssociatedTagsEmbedding(for memo: Memo) async {
        for tagId in memo.tagIds {
            if let currentTag = tags.first(where: { $0.id == tagId }) {
                let tagEmbedding = currentTag.embeddingVector
                
                // 태그 임베딩 업데이트
                let updatedEmbedding = updateTagEmbeddingWithAI(memoEmbeddingVector: memo.embeddingVector, tagEmbeddingVector: tagEmbedding)
                
                let currentDate = Date()
                
                // 태그 업데이트 요청
                let result = await useCases.updateTagUseCase.execute(id: currentTag.id, name: currentTag.name, color: currentTag.color, embeddingVector: updatedEmbedding, createdAt: currentTag.createdAt, updatedAt: currentDate)
                
                switch result {
                case .success(let updatedTag):
                    var newTag = updatedTag
                    newTag.embeddingVector = updatedEmbedding // 임베딩 벡터 할당
                    
                    // Main과 Search의 태그 목록에서 업데이트
                    if let index = self.tags.firstIndex(where: { $0.id == updatedTag.id }) {
                        self.tags[index] = newTag
                    }
                    if let index = self.searchedTags.firstIndex(where: { $0.id == updatedTag.id }) {
                        self.searchedTags[index] = newTag
                    }
                    
                case .failure(let error):
                    print("태그 임베딩 업데이트 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Recommend Functions
    
    /// contentEmbeddingVector와 self.memos의 각 embeddingVector와 similarity를 구해서,
    /// threshold 이상인 메모들을 similarity 기준 내림차순으로 정렬하여 반환한다.
    func recommendMemosWithAI(contentEmbeddingVector: [Float]) -> [Memo] {
        let threshold: Float = 0.7
        let memoSimilarities = memos.compactMap { memo -> (memo: Memo, similarity: Float)? in
            if let similarity = try? AIModel.shared.cosineSimilarity(vectorA: contentEmbeddingVector, vectorB: memo.embeddingVector),
               similarity >= threshold {
                return (memo, similarity)
            } else {
                return nil
            }
        }
        let sortedMemos = memoSimilarities.sorted { $0.similarity > $1.similarity }
        return sortedMemos.map { $0.memo }
    }
    
    /// contentEmbeddingVector와 self.tags의 각 embeddingVector와 similarity를 구해서,
    /// similarity 기준 내림차순으로 정렬된 태그 배열을 반환한다.
    func recommendTagsWithAI(contentEmbeddingVector: [Float]) -> [Tag] {
        let tagNames = tags.map { $0.name }
        
        guard let tagEmbeddings = try? AIModel.shared.encode(texts: tagNames) else { return [] }
        
        let tagSimilarities = zip(tags, tagEmbeddings).compactMap { (tag, embedding) -> (tag: Tag, similarity: Float)? in
            if let similarity = try? AIModel.shared.cosineSimilarity(vectorA: contentEmbeddingVector, vectorB: embedding) {
                return (tag, similarity)
            } else {
                return nil
            }
        }
        
        let sortedTags = tagSimilarities.sorted { $0.similarity > $1.similarity }
        return sortedTags.map { $0.tag }
    }
    
    /// editorContent와 editorTags를 읽고 recommendingMemos와 recommendingTags를 업데이트한다.
    func recommendMemosAndTags() {
        print("recommendMemosAndTags()")
        // 편집창에 내용과 태그 모두 비어있으면 메모는 아무것도 추천 안하고, 태그는 관련성 없이 전부 추천함
        if self.editorContent.isEmpty && self.editorTags.isEmpty {
            self.recommendingMemos = []
            self.recommendingTags = self.tags
            return
        }
      
        Task {
            do {
                // editorContent를 읽어서 임베딩 벡터 생성
                let embeddingVector = try await createEmbeddingVectorWithAI(text: self.editorContent)
                
                // 편집창에 있는 태그의 ID들을 추출
                let editorTagIds = editorTags.map { $0.id }
                
                // 그룹 A: 태그 매칭되는 메모 (update 상태 제외)
                let groupAMemos = memos.filter { memo in
                    memo.tagIds.contains(where: { editorTagIds.contains($0) }) &&
                    !(editorState == .update(target: memo))
                }
                
                // 그룹 B: AI 기반 추천 메모 중, 태그 매칭되지 않는 메모들 (이미 그룹 A에 포함된 것은 제외)
                let groupBMemos = recommendMemosWithAI(contentEmbeddingVector: embeddingVector).filter { memo in
                    !memo.tagIds.contains(where: { editorTagIds.contains($0) })
                }
                
                // 최종 추천 메모: 그룹 A(태그 매칭) + 그룹 B(유사도 순)
                let finalRecommendedMemos = groupAMemos + groupBMemos
                
                // 태그 추천
                let recommendedTags = recommendTagsWithAI(contentEmbeddingVector: embeddingVector)
                
                // UI 업데이트
                DispatchQueue.main.async {
                    self.recommendingMemos = finalRecommendedMemos
                    self.recommendingTags = recommendedTags
                }
            } catch {
                appState.system.showAlert = true
                appState.system.errorMessage = "추천 시스템에서 오류가 발생했습니다: \(error.localizedDescription)"
            }
        }
    }


    // MARK: - Search Functions
    
    /// searchTextEmbeddingVector와 self.memos의 각 embeddingVector와 similarity를 구해서,
    /// threshold 이상인 메모들을 similarity 기준 내림차순으로 정렬하여 반환한다.
    func searchMemosWithAI(searchTextEmbeddingVector: [Float]) -> [Memo] {
        let threshold: Float = 0.7
        let memoSimilarities = memos.compactMap { memo -> (memo: Memo, similarity: Float)? in
            if let similarity = try? AIModel.shared.cosineSimilarity(vectorA: searchTextEmbeddingVector, vectorB: memo.embeddingVector),
               similarity >= threshold {
                return (memo, similarity)
            } else {
                return nil
            }
        }
        let sortedMemos = memoSimilarities.sorted { $0.similarity > $1.similarity }
        return sortedMemos.map { $0.memo }
    }
    
    /// searchTextEmbeddingVector와 self.tags의 각 embeddingVector와 similarity를 구해서,
    /// threshold 이상인 태그들을 similarity 기준 내림차순으로 정렬하여 반환한다.
    func searchTagsWithAI(searchTextEmbeddingVector: [Float]) -> [Tag] {
        let threshold: Float = 0.7
        let tagSimilarities = tags.compactMap { tag -> (tag: Tag, similarity: Float)? in
            if let similarity = try? AIModel.shared.cosineSimilarity(vectorA: searchTextEmbeddingVector, vectorB: tag.embeddingVector),
               similarity >= threshold {
                return (tag, similarity)
            } else {
                return nil
            }
        }
        let sortedTags = tagSimilarities.sorted { $0.similarity > $1.similarity }
        return sortedTags.map { $0.tag }
    }
    
    /// searchBarText를 읽어서 searchedMemos와 searchedTags를 업데이트한다.
    func searchMemosAndTags() {
        // 검색창이 비어있으면 검색 결과를 전부 비우기
        if self.searchBarText.isEmpty && self.searchBarSelectedTags.isEmpty {
            self.searchedMemos = []
            self.searchedTags = []
            return
        }
        
        Task {
            do {
                // searchBarText를 읽어서 임베딩 벡터 생성
                let embeddingVector = try await createEmbeddingVectorWithAI(text: self.searchBarText)
                
                // 선택된 태그의 ID들을 추출
                let selectedTagIds = searchBarSelectedTags.map { $0.id }
                
                // 그룹 A: 단순 문자열 매칭으로 검색 (선택된 태그를 모두 포함하고, content에 검색어가 포함된 메모)
                let groupAMemos = memos.filter { memo in
                    // 메모의 내용이 검색어를 포함하고
                    (self.searchBarText.isEmpty || memo.content.contains(self.searchBarText)) &&
                    // 선택된 태그를 모두 포함하는 경우
                    selectedTagIds.allSatisfy { memo.tagIds.contains($0) }
                }
                
                // 그룹 B: threshold 이상인 메모들을 유사도 기준 내림차순으로 정렬 (이미 정렬된 결과)
                let groupBMemos = searchMemosWithAI(searchTextEmbeddingVector: embeddingVector)
                
                
                // 그룹 A와 그룹 B를 중복 없이 결합 (그룹 A가 앞쪽에 오도록)
                var combinedMemos = groupAMemos
                for memo in groupBMemos where !groupAMemos.contains(where: { $0.id == memo.id }) {
                    combinedMemos.append(memo)
                }
                
                // 그룹 A: 이름 문자열 매칭으로 검색 (모든 태그 중 검색어 포함)
                let groupATags = tags.filter { tag in
                    tag.name.contains(self.searchBarText)
                }
                
                // 그룹 B: 기존 유사도 기반 검색 결과 (threshold 이상인 태그들을 similarity 기준 내림차순)
                let groupBTags = searchTagsWithAI(searchTextEmbeddingVector: embeddingVector)
                
                // 그룹 A와 그룹 B를 중복 없이 결합 (그룹 A가 앞쪽에 오도록)
                var combinedTags = groupATags
                for tag in groupBTags where !combinedTags.contains(where: { $0.id == tag.id }) {
                    combinedTags.append(tag)
                }
                
                // UI 업데이트
                DispatchQueue.main.async {
                    self.searchedMemos = combinedMemos
                    self.searchedTags = combinedTags
                }
            } catch {
                appState.system.showAlert = true
                appState.system.errorMessage = "검색 시스템에서 오류가 발생했습니다: \(error.localizedDescription)"
            }
        }
    }
}
