//
//  AppState.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation
import Factory

@MainActor
@Observable
final class AppState {
    // 기본 정보
    var user: User?
    var tags: [Tag] = []
    // 잠금해제 관련
    var isBioAuthenticated: Bool = false
    // 태그 관련 설정
    var tagOrdering: TagOrdering = .dateAdded
    var isOnMemoTagSorting: Bool = false
    var favoriteTags: [TagID] = []
    // 글자 크기 관련 설정
    var fontSize: FontSize = .small
    enum FontSize: Codable {
        case small
        case medium
        case large
    }
    
    func initialize() {
        Container.shared.mainViewModel.reset()
        user = nil
        tags = []
        isBioAuthenticated = false
        tagOrdering = .dateAdded
        isOnMemoTagSorting = false
        favoriteTags = []
        fontSize = .small
    }
}

extension AppState {
    private func sortTags(_ tags: [Tag]) -> [Tag] {
        switch tagOrdering {
        case .alphabetical:
            return tags.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .dateAdded:
            return tags
        case .color:
            return tags.sorted { $0.color.sortOrder < $1.color.sortOrder }
        }
    }
    
    var sortedTags: [Tag] {
        let favoriteSet = Set(favoriteTags)
        let favorites = tags.filter { favoriteSet.contains($0.id) }
        let nonFavorites = tags.filter { !favoriteSet.contains($0.id) }
        
        return sortTags(favorites) + sortTags(nonFavorites)
    }
    
    func tags(for ids: [TagID]) -> [Tag] {
        if isOnMemoTagSorting {
            let idSet = Set(ids)
            return sortedTags.filter { idSet.contains($0.id) }
        } else {
            let tagDict = Dictionary(uniqueKeysWithValues: tags.map { ($0.id, $0) })
            return ids.compactMap { tagDict[$0] }
        }
    }
}

extension Container {
    @MainActor
    var appState: Factory<AppState> {
        self { @MainActor in AppState() }.singleton
    }
}
