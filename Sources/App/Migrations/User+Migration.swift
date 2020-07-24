//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/21.
//  
//

import Fluent

extension User {
    struct Migration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("users")
                .id()
                .field("email", .string, .required)
                .field("password_hash", .string, .required)
                .unique(on: "email")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("users").delete()
        }
    }
}
