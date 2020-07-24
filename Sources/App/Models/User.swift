//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/21.
//  
//


import Foundation
import Vapor
import Fluent

final class User: Content, Model {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    init() {}

    init(id: UUID? = nil, email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
}


extension User: ModelAuthenticatable {
    static var usernameKey: KeyPath<User, Field<String>> = \User.$email
    static var passwordHashKey: KeyPath<User, Field<String>> = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

// MARK: - User.Create
extension User {
    struct Create: Content {
        var email: String
        var password: String
        var confirmPassword: String // 確認密碼
    }
}

// MARK: - Validation 格式驗證
extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        // email格式須符合`.email`格式
        validations.add("email", as: String.self, is: .email, required: true)
        // password需為8~16碼
        validations.add("password", as: String.self, is: .count(8...16))
    }
}

// MARK: Generate UserToken
extension User {
    func generateToken() throws -> UserToken {
        // 產生一組新Token, 有效期限為一天
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .day, value: 1, to: Date())

        return try UserToken(value: [UInt8].random(count: 16).base64, expireTime: expiryDate, userID: self.requireID())
    }
}

