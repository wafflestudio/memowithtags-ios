//
//  UserState.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/14/25.
//

import SwiftUI

@MainActor
final class UserState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isBioAuthenticated: Bool = false
    
    @Published var userId: String?
    @Published var userNumber: Int?
    @Published var userName: String?
    @Published var userEmail: String?
    @Published var isSocial: Bool = false
}
