//
//  User.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

struct UserDto: Codable {
    let id: String
    let userNumber: Int
    let email: String
    let nickname: String
    let isSocial: Bool
    let createdAt: String
    
    func toUser() -> User {
        return User(id: id, userNumber: userNumber, email: email, nickname: nickname, isSocial: isSocial)
    }
}
