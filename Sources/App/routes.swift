import Fluent
import Vapor

func routes(_ app: Application) throws {
    let passwordProtected = app.grouped(User.authenticator())
    let tokenProtected = app.grouped(UserToken.authenticator())

    app.post("create") { req -> EventLoopFuture<User> in
        // 驗證格式，不在這次重點
        try User.Create.validate(content: req)

        // 從request body中decode出User.Create
        let newUser = try req.content.decode(User.Create.self)

        // 先檢查密碼是否==確認密碼
        guard newUser.password == newUser.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }

        // 將User.Create 轉成 User
        let user = try User(email: newUser.email, passwordHash: Bcrypt.hash(newUser.password))

        // 儲存User並回傳
        return user.save(on: req.db).map { user }
    }

    passwordProtected.post("login") { req -> EventLoopFuture<UserToken> in
        // Basic驗證
        let user = try req.auth.require(User.self)
        // 驗證過了就產生Token
        let token = try user.generateToken()
        return token.save(on: req.db).map { token }
    }

    tokenProtected.get("otherRequest") { req -> EventLoopFuture<User> in
        // Bearer驗證
        let user = try req.auth.require(User.self)
        
        // 做api該做的事 比如取得User資訊
        return User.find(user.id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}
