//
//  LocalRepository.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/19/25.
//

import Foundation

protocol LocalRepository {
    func set<T: Codable>(_ value: T, forKey key: String) throws
    func get<T: Codable>(forKey key: String, as type: T.Type) throws -> T?
    func remove(forKey key: String)
    func contains(key: String) -> Bool
}
