//
//  DefaultFileManagerRepository.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/29/25.
//

import Foundation

final class DefaultFileManagerRepository: FileManagerRepository {
    
    private let fileManager: FileManager
    private let memosFileURL: URL
    private let tagsFileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.memosFileURL = documentsDirectory.appendingPathComponent("memos.json")
        self.tagsFileURL = documentsDirectory.appendingPathComponent("tags.json")
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.outputFormatting = .prettyPrinted
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    /// Loads memos and tags from the file system.
    func loadMemosAndTags() async throws -> (memos: [Memo], tags: [Tag]) {
        async let memos = loadMemos()
        async let tags = loadTags()
        return try await (memos, tags)
    }
    
    /// Saves memos and tags to the file system.
    func saveMemosAndTags(memos: [Memo], tags: [Tag]) async throws {
        async let saveMemosTask: () = saveMemos(memos)
        async let saveTagsTask: () = saveTags(tags)
        try await saveMemosTask
        try await saveTagsTask
    }
    
    /// Loads memos from the memos.json file.
    private func loadMemos() async throws -> [Memo] {
        do {
            let data = try Data(contentsOf: memosFileURL)
            let memos = try decoder.decode([Memo].self, from: data)
            return memos
        } catch let error as NSError {
            print(error)
            throw FileManagerError(error)
        }
    }
    
    /// Loads tags from the tags.json file.
    private func loadTags() async throws -> [Tag] {
        do {
            let data = try Data(contentsOf: tagsFileURL)
            let tags = try decoder.decode([Tag].self, from: data)
            return tags
        } catch let error as NSError {
            throw FileManagerError(error)
        }
    }
    
    /// Saves memos to the memos.json file.
    private func saveMemos(_ memos: [Memo]) async throws {
        do {
            let data = try encoder.encode(memos)
            try data.write(to: memosFileURL, options: [.atomicWrite, .completeFileProtection])
        } catch let error as NSError {
            throw FileManagerError(error)
        }
    }
    
    /// Saves tags to the tags.json file.
    private func saveTags(_ tags: [Tag]) async throws {
        do {
            let data = try encoder.encode(tags)
            try data.write(to: tagsFileURL, options: [.atomicWrite, .completeFileProtection])
        } catch let error as NSError {
            throw FileManagerError(error)
        }
    }
}
