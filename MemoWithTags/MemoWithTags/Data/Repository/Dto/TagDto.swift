//
//  Tag.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation
import SwiftUI

struct TagDto: Decodable {
    let id: UUID
    let name: String
    let colorHex: String
    let embeddingVector: [Float]
    let createdAt: String
    let updatedAt: String

    func toTag() -> Tag {
        let tagColor = Color.TagColor.allCases.first {
            $0.rawValue.lowercased() == colorHex.lowercased()
        } ?? .color1

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return Tag(
            id: id,
            name: name,
            color: tagColor,
            embeddingVector: embeddingVector,
            createdAt: dateFormatter.date(from: createdAt) ?? Date(),
            updatedAt: dateFormatter.date(from: updatedAt) ?? Date()
        )
    }
}
