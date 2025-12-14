import Foundation
import FlorShopDTOs

struct TokenRefreshable: Sendable, Codable {
    let id: String
    let identifier: TokenRefresableIdentifier
    let accessToken: String
    let refreshToken: String?
    let accessTokenExpiry: Date
    init(
        id: String,
        identifier: TokenRefresableIdentifier,
        accessToken: String,
        refreshToken: String?,
        accessTokenExpiry: Date
    ) {
        self.id = id
        self.identifier = identifier
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiry = accessTokenExpiry
    }
    func refreshToken() async throws -> Self {
        guard let refreshToken else { throw NetworkError.dataNotFound }
        let request = FlorShopAuthApiRequest.refresh(request: RefreshTokenRequest(refreshToken: accessToken, identifier: identifier))
        let response = try await NetworkManager.shared.perform(request, decodeTo: ScopedTokenResponse.self)
        let token = TokenRefreshable(
            id: id,
            identifier: identifier,
            accessToken: response.scopedToken,
            refreshToken: refreshToken,
            accessTokenExpiry: jwtExpiry(from: response.scopedToken) ?? Date().addingTimeInterval(60*15)
        )
        return token
    }
    func jwtExpiry(from token: String) -> Date? {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return nil }

        let payload = parts[1]

        // Base64URL → Base64
        var base64 = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Rellenar con "=" para múltiplos de 4
        while base64.count % 4 != 0 {
            base64 += "="
        }

        guard let data = Data(base64Encoded: base64) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        guard let exp = json["exp"] as? TimeInterval else { return nil }

        return Date(timeIntervalSince1970: exp)
    }
}
