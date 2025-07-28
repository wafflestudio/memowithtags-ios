//
//  Pipeline.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/1/25.
//

import Foundation
import Factory
import SwiftUI

@MainActor
@Observable
class Action<Item> {
    var signal: Bool = false
    var items: [Item] = []
    var namespace: Namespace.ID!
    
    func push(_ item: Item) {
        items.append(item)
        signal.toggle()
    }
    
    func pop() -> Item? {
        return items.popLast()
    }
}

struct ContextMenuItem: Identifiable {
    var id: UUID = UUID()
    var position: CGRect
    var preview: PreviewType
    var menu: [MenuElement]
}

struct ExpandAnimationItem: Identifiable {
    var id: UUID = UUID()
    var content: String
    var tags: [TagID]
    var editState: EditState
}

struct TagUpdateItem: Identifiable {
    var id: UUID = UUID()
    var tag: Tag
}

extension Container {
    @MainActor
    var contextMenuAction: Factory<Action<ContextMenuItem>> {
        self { @MainActor in Action<ContextMenuItem>() }.singleton
    }
    
    @MainActor
    var expandAction: Factory<Action<ExpandAnimationItem>> {
        self { @MainActor in Action<ExpandAnimationItem>() }.singleton
    }
    
    @MainActor
    var tagUpdateAction: Factory<Action<TagUpdateItem>> {
        self { @MainActor in Action<TagUpdateItem>() }.singleton
    }
}
