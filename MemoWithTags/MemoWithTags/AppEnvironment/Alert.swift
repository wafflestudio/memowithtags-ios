//
//  Alert.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/21/25.
//

import Foundation
import Factory

@MainActor
@Observable
final class Alert {
    var showAlert: Bool = false
    var error: Error? = nil
    
    func alert(error: Error) {
        self.showAlert = true
        self.error = error
    }
}

extension Container {
    @MainActor
    var alert: Factory<Alert> {
        self { @MainActor in Alert() }.singleton
    }
}
