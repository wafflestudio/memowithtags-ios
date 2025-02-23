//
//  SystemState.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/13/25.
//

import Foundation

@MainActor
final class SystemState: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var error: Error? = nil
    
    func alert(error: Error) {
        self.showAlert = true
        self.error = error
    }
}
