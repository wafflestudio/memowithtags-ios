//
//  MemoEditorViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/21/25.
//

import Foundation
import SwiftUI
import Factory

@MainActor
@Observable
final class MemoEditorViewModel {
    var editorState: EditorState = .create
    var editorContent: String = ""
    var editorTagIds: [Int] = []
    
    enum EditorState {
        case create
        case update(target: Memo)
    }
}

extension Container {
    @MainActor
    var memoEditorViewModel: Factory<MemoEditorViewModel> {
        self { @MainActor in MemoEditorViewModel() }.singleton
    }
}
