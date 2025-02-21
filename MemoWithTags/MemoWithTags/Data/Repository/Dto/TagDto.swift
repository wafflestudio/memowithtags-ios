//
//  Tag.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation
import SwiftUI

struct TagDto: Decodable {
    let id: Int
    let name: String
    let colorHex: String

    func toTag() -> Tag {
        
        let tagColor = Color.TagColor.allCases.first {
            $0.rawValue.lowercased() == colorHex.lowercased()
        } ?? .color1
        
        return Tag(
            id: id,
            name: name,
            color: tagColor
        )
    }
}
