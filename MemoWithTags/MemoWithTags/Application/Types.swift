//
//  Types.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/28/25.
//

typealias TagID = Int

extension Array where Element == TagID {
    func toTags(from tags: [Tag]) -> [Tag] {
        tags.filter { self.contains($0.id) }
    }
}

enum EditState {
    case create
    case update(memo: Memo)
}
