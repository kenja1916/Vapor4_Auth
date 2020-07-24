//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/21.
//  
//


import Foundation
import Fluent

extension UserToken {
    struct Migration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("user_tokens")
                .id()
                .field("value", .string, .required)
                .field("expire_time", .date)
                                        // 關聯到schema="users"的"id"欄位
                .field("user_id", .uuid, .references("users", "id"))
                .unique(on: "value")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("user_tokens").delete()
        }
    }
}
