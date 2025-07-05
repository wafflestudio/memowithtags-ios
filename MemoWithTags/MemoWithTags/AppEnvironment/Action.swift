//
//  Pipeline.swift
//  MemoWithTags
//
//  Created by 최진모 on 7/1/25.
//

import Foundation
import Factory

@MainActor
@Observable
class Action<Item> {
    var signal: Bool = false
    var items: [Item] = []
    
    private func sendSignal() {
        signal.toggle()
    }
    
    func push(_ item: Item) {
        items.append(item)
        sendSignal()
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

extension Container {
    @MainActor
    var contextMenuAction: Factory<Action<ContextMenuItem>> {
        self { @MainActor in Action<ContextMenuItem>() }.singleton
    }
}
