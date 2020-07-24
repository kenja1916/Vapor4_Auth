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

final class UserToken: Content, Model {
    static let schema: String = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Field(key: "expireTime")
    var expireTime: Date?

    @Parent(key: "user_id")
    var user: User


    init() { }

    init(id: UUID? = nil, value: String, expireTime: Date?, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.expireTime = expireTime
        self.$user.id = userID
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static var valueKey = \UserToken.$value
    static var userKey = \UserToken.$user

    var isValid: Bool {
        guard let expireTime = expireTime else { return false }
        return expireTime > Date()
    }
}
