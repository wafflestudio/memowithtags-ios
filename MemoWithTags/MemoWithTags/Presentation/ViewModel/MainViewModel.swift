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
    
    // MARK: - Main Page Variables
    @Published var memos: [Memo] = []
    @Published var tags: [Tag] = []
    @Published var recommendingMemos: [Memo] = []
    @Published var recommendingTags: [Tag] = []
    // 참고: 사용자가 태그 검색 창에 검색을 한다고 recommendingTags는 변하지 않는다.
    // tagRecommendation에 recommendingTags가 그대로 보이는 것이 아니라, 검색을 하는 등 추가적인 과정이 있다.
    
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
    @Published var sortSearch: Sort = .byCreate
    
    enum Sort {
        case byCreate
        case byUpdate
    }
    
    // MARK: Load and Save Opeartions between Filesystem
    
    func loadMemosAndTagsFromFileSystem() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await useCases.loadMemosAndTagsUseCase.execute()
        
        switch result {
        case .success(let data):
            self.memos = data.memos
            self.tags = data.tags
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func saveMemosAndTagsToFileSystem() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await useCases.saveMemosAndTagsUseCase.execute(memos: self.memos, tags: self.tags)
        
        switch result {
        case .success():
            print("Memos and Tags successfully saved to filesystem.")
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
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
                appState.system.showAlert = true
                appState.system.errorMessage = error.localizedDescription
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
                appState.system.showAlert = true
                appState.system.errorMessage = error.localizedDescription
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
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
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
            case .failure(let error):
                appState.system.showAlert = true
                appState.system.errorMessage = error.localizedDescription
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
            case .failure(let error):
                appState.system.showAlert = true
                appState.system.errorMessage = error.localizedDescription
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
        case .failure(let error):
            appState.system.showAlert = true
            appState.system.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Initialization and User Info
    
    /// Main View가 나타날 때 호출되는 초기화 함수
    func initMainViewModel() async {
        if memos.isEmpty || tags.isEmpty {
            await loadMemosAndTagsFromFileSystem()
            // 파일 시스템에서 가져오기 실패할 경우 서버에서 데이터를 가져오는 로직을 추가할 수 있습니다.
        }
    }
    
    /// Settings View에서 유저 정보를 가져오는 함수
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
            appState.system.errorMessage = error.localizedDescription
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
            appState.system.errorMessage = error.localizedDescription
        }
    }
    
    /// Editor에서 Submit 했을 때 작동
    func submit() async {
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
        hideKeyboard()
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
    
    /// contentEmbeddingVector와 self.memos의 각 embeddingVector와 similarity를 구해서 threshold 이상인 메모들을 모아서 반환한다.
    func recommendMemosWithAI(contentEmbeddingVector: [Float]) -> [Memo] {
        let threshold: Float = 0.7
        return memos.filter { memo in
            let similarity = try? AIModel.shared.cosineSimilarity(vectorA: contentEmbeddingVector, vectorB: memo.embeddingVector)
            return (similarity ?? 0.0) >= threshold
        }
    }
    
    /// contentEmbeddingVector와 self.tags의 각 embeddingVector와 similarity를 구해서 similarity가 높은 순서대로 태그 배열을 반환한다.
    func recommendTagsWithAI(contentEmbeddingVector: [Float]) -> [Tag] {
        let tagNames = tags.map { $0.name }
        
        // 태그 임베딩을 시도하고 실패 시 빈 배열 반환
        guard let tagEmbeddings = try? AIModel.shared.encode(texts: tagNames) else { return [] }
        
        // 유사도 계산 시 에러 처리
        let tagSimilarities = zip(tags, tagEmbeddings).compactMap { tag, embedding -> (Tag, Float)? in
            if let similarity = try? AIModel.shared.cosineSimilarity(vectorA: contentEmbeddingVector, vectorB: embedding) {
                return (tag, similarity)
            } else {
                return nil
            }
        }
        
        // 유사도 순으로 정렬
        let sortedTags = tagSimilarities.sorted { $0.1 > $1.1 }
        
        return sortedTags.map { $0.0 }
    }
    
    /// editorContent를 읽고 recommendingMemos와 recommendingTags를 업데이트한다.
    func recommendMemosAndTags() {
        Task {
            do {
                // editorContent를 읽어서 임베딩 벡터 생성
                let embeddingVector = try await createEmbeddingVectorWithAI(text: self.editorContent)
                
                // 메모 추천
                var recommendedMemos = recommendMemosWithAI(contentEmbeddingVector: embeddingVector)
                
                // 편집창에 있는 태그의 ID를 추출
                let editorTagIds = editorTags.map { $0.id }
                
                // 편집창에 있는 태그를 가지고 있는 메모를 추가로 필터링
                let additionalMemos = memos.filter { memo in
                    // 메모가 이미 추천된 메모에 포함되어 있지 않은지 확인
                    !recommendedMemos.contains(where: { $0.id == memo.id }) &&
                    // 메모의 태그 중 하나라도 현재 편집 중인 태그에 포함되는지 확인
                    memo.tagIds.contains(where: { editorTagIds.contains($0) }) &&
                    // 현재 update 상태인 메모는 제외
                    !(editorState == .update(target: memo))
                }
                recommendedMemos.append(contentsOf: additionalMemos)
                
                // 태그 추천
                var recommendedTags = recommendTagsWithAI(contentEmbeddingVector: embeddingVector)
                
                // 이미 선택되어 편집창에 있는 태그의 ID를 추출하여 제외
                let selectedTagIds = editorTags.map { $0.id }
                recommendedTags = recommendedTags.filter { !selectedTagIds.contains($0.id) }
                
                // UI 업데이트
                DispatchQueue.main.async {
                    self.recommendingMemos = recommendedMemos
                    self.recommendingTags = recommendedTags
                }
            } catch {
                appState.system.showAlert = true
                appState.system.errorMessage = "추천 시스템에서 오류가 발생했습니다: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Search Functions
    
    /// searchTextEmbeddingVector와 self.memos의 각 embeddingVector와 similarity를 구해서 threshold 이상인 메모들을 모아서 반환한다.
    func searchMemosWithAI(searchTextEmbeddingVector: [Float]) -> [Memo] {
        let threshold: Float = 0.7
        return memos.filter { memo in
            let similarity = try? AIModel.shared.cosineSimilarity(vectorA: searchTextEmbeddingVector, vectorB: memo.embeddingVector)
            return (similarity ?? 0.0) >= threshold
        }
    }
    
    /// searchTextEmbeddingVector와 self.tags의 각 embeddingVector와 similarity를 구해서 similarity가 높은 순서대로 태그 배열을 반환한다.
    func searchTagsWithAI(searchTextEmbeddingVector: [Float]) -> [Tag] {
        let tagNames = tags.map { $0.name }
        
        // 태그 임베딩을 시도하고 실패 시 빈 배열 반환
        guard let tagEmbeddings = try? AIModel.shared.encode(texts: tagNames) else { return [] }
        
        // 유사도 계산 시 에러 처리
        let tagSimilarities = zip(tags, tagEmbeddings).compactMap { tag, embedding -> (Tag, Float)? in
            if let similarity = try? AIModel.shared.cosineSimilarity(vectorA: searchTextEmbeddingVector, vectorB: embedding) {
                return (tag, similarity)
            } else {
                return nil
            }
        }
        
        // 유사도 순으로 정렬
        let sortedTags = tagSimilarities.sorted { $0.1 > $1.1 }
        
        return sortedTags.map { $0.0 }
    }
    
    /// searchBarText를 읽어서 searchedMemos와 searchedTags를 업데이트한다.
    func searchMemosAndTags() {
        Task {
            do {
                // searchBarText를 읽어서 임베딩 벡터 생성
                let embeddingVector = try await createEmbeddingVectorWithAI(text: self.searchBarText)
                
                // 메모 검색
                var foundMemos = searchMemosWithAI(searchTextEmbeddingVector: embeddingVector)
                
                // 선택된 태그의 ID를 추출
                let selectedTagIds = searchBarSelectedTags.map { $0.id }
                
                // 선택된 태그를 가지고 있는 메모를 추가로 필터링
                let additionalMemos = memos.filter { memo in
                    // 메모가 이미 검색된 메모에 포함되어 있지 않은지 확인
                    !foundMemos.contains(where: { $0.id == memo.id }) &&
                    // 메모의 태그 중 하나라도 사용자가 선택한 태그에 포함되는지 확인 - 수정 필요
                    memo.tagIds.contains(where: { selectedTagIds.contains($0) })
                }
                foundMemos.append(contentsOf: additionalMemos)
                
                // 태그 검색
                var foundTags = searchTagsWithAI(searchTextEmbeddingVector: embeddingVector)
                
                // 태그 이름과 매칭되는 태그를 추가
                let matchingTags = tags.filter { $0.name.contains(searchBarText) }
                foundTags.append(contentsOf: matchingTags)
                
                // 선택된 태그의 ID를 추출하여 제외
                let filteredTags = foundTags.filter { !selectedTagIds.contains($0.id) }
                
                // UI 업데이트
                DispatchQueue.main.async {
                    self.searchedMemos = foundMemos
                    self.searchedTags = filteredTags
                }
            } catch {
                appState.system.showAlert = true
                appState.system.errorMessage = "검색 시스템에서 오류가 발생했습니다: \(error.localizedDescription)"
            }
        }
    }
}

