import Foundation
import FlorShopDTOs

actor TokenProvider {
    private var currentToken: TokenRefreshable?
    private let store: TokenStore
    private var refreshTask: Task<TokenRefreshable, Error>?
    
    static let shared = TokenProvider()
    
    private init() {
        self.store = TokenStore()
    }
    
    func save(token: TokenRefreshable) async {
        if case .scopedToken = token.identifier {
            self.currentToken = token
        }
        try? await self.store.save(token)
    }
    
    func currentScopedToken() async throws -> String? {
        guard let currentToken else {
            return nil
        }
        return try await authHeader(identifier: currentToken.identifier)
    }
    
    func authHeader(identifier: TokenRefresableIdentifier) async throws -> String? {
        var bearerToken: TokenRefreshable
        if let currentToken,
           case .scopedToken(let subsidiaryCic) = currentToken.identifier,
           subsidiaryCic == identifier.identifier {
            bearerToken = currentToken
        } else {
            guard let token = try await self.store.load(identifier: identifier) else {
                throw NetworkError.dataNotFound
            }
            bearerToken = token
        }
        if try await needsRefresh(token: bearerToken) {
            bearerToken = try await refreshIfNeeded(token: bearerToken, identifier: identifier)
        }
        return "Bearer \(bearerToken.accessToken)"
    }
    
    func getToken(identifier: TokenRefresableIdentifier) async throws -> TokenRefreshable? {
        var bearerToken: TokenRefreshable
        if let currentToken,
           case .scopedToken(let subsidiaryCic) = currentToken.identifier,
           subsidiaryCic == identifier.identifier {
            bearerToken = currentToken
        } else {
            guard let token = try await self.store.load(identifier: identifier) else {
                throw NetworkError.dataNotFound
            }
            bearerToken = token
        }
        if try await needsRefresh(token: bearerToken) {
            bearerToken = try await refreshIfNeeded(token: bearerToken, identifier: identifier)
        }
        return bearerToken
    }
    
    private func needsRefresh(token: TokenRefreshable) async throws -> Bool {
        let buffer: TimeInterval = 60
        return Date() >= token.accessTokenExpiry.addingTimeInterval(-buffer)
    }
    
    func refreshIfNeeded(token: TokenRefreshable, identifier: TokenRefresableIdentifier) async throws -> TokenRefreshable {
        if let t = refreshTask { return try await t.value }
        let task = Task<TokenRefreshable, Error> {
            defer { Task { await clearRefreshTask() } }
            guard let newToken = try? await token.refreshToken() else {
                try await store.clear(identifier: identifier)
                throw NetworkError.dataNotFound
            }
            await self.save(token: newToken)
            return newToken
        }
        refreshTask = task
        return try await task.value
    }
    
    private func clearRefreshTask() async {
        refreshTask = nil
    }
}
