//
//  DefaultLocalRepository.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/19/25.
//

import Foundation
import Factory

class DefaultLocalRepository: LocalRepository {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    /// 저장
    func set<T: Codable>(_ value: T, forKey key: String) throws {
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key)
        } catch {
            throw LocalError.encodingFailed
        }
    }
    
    /// 불러오기
    func get<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw LocalError.decodingFailed
        }
    }
    
    /// 삭제
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    /// 존재 여부
    func contains(key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
}

extension Container {
    var localRepository: Factory<LocalRepository> {
        self { DefaultLocalRepository() }.singleton
    }
}
