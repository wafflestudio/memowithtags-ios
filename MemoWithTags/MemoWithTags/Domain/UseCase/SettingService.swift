//
//  SettingService.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/19/25.
//

import SwiftUI
import Factory

protocol SettingService {
    func getTagOrdering(userId: Int) throws -> TagOrdering
    func getOnMemoTagSorting(userId: Int) throws -> Bool
    func getFavoriteTags(userId: Int) throws -> [TagID]
    func sortTag(by order: TagOrdering, userId: Int) throws
    func togleMemoTagSorting(_ value: Bool, userId: Int) throws
    func addFavoriteTag(with tagId: TagID, userId: Int) throws
    func removeFavoriteTag(with tagId: TagID, userId: Int) throws
}

final class DefaultSettingServerice: SettingService {
    @Injected(\.localRepository) private var localRepository
    
    func getTagOrdering(userId: Int) throws -> TagOrdering {
        if let tagOrdering = try localRepository.get(forKey: "\(userId)/TagOrdering", as: TagOrdering.self) {
            return tagOrdering
        }
        return .dateAdded
    }
    
    func getOnMemoTagSorting(userId: Int) throws -> Bool {
        if let onMemoTagSorting = try localRepository.get(forKey: "\(userId)/OnMemoTagSorting", as: Bool.self) {
            return onMemoTagSorting
        }
        return false
    }
    
    func getFavoriteTags(userId: Int) throws -> [TagID] {
        if let favoriteTags = try localRepository.get(forKey: "\(userId)/FavoriteTags", as: [Int].self) {
            return favoriteTags
        }
        return []
    }
    
    func sortTag(by order: TagOrdering, userId: Int) throws {
        try localRepository.set(order, forKey: "\(userId)/TagOrdering")
    }
    
    func togleMemoTagSorting(_ value: Bool, userId: Int) throws {
        try localRepository.set(value, forKey: "\(userId)/OnMemoTagSorting")
    }
    
    func addFavoriteTag(with tagId: TagID, userId: Int) throws {
        if localRepository.contains(key: "\(userId)/FavoriteTags") {
            if var favoriteTags = try localRepository.get(forKey: "\(userId)/FavoriteTags", as: [Int].self) {
                favoriteTags.append(tagId)
                try localRepository.set(favoriteTags, forKey: "\(userId)/FavoriteTags")
            }
        } else {
            try localRepository.set([tagId], forKey: "\(userId)/FavoriteTags")
        }
    }
    
    func removeFavoriteTag(with tagId: TagID, userId: Int) throws {
        if var favoriteTags = try localRepository.get(forKey: "\(userId)/FavoriteTags", as: [Int].self) {
            favoriteTags.removeAll { $0 == tagId }
            try localRepository.set(favoriteTags, forKey: "\(userId)/FavoriteTags")
        }
    }
}

extension Container {
    var settingService: Factory<SettingService> {
        self { DefaultSettingServerice() }.singleton
    }
}

