//
//  Tag.swift
//  MemoWithTags
//
//  Created by 최진모 on 12/26/24.
//
import Foundation
import SwiftUI

struct Tag: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var color: Color.TagColor
    var embeddingVector: [Float]
    var createdAt: Date
    var updatedAt: Date
}
