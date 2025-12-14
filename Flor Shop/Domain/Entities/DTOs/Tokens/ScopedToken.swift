import Foundation

struct ScopedTokenPayload: Decodable {
    let sub: String
    let companyCic: String
    let subsidiaryCic: String
    let isOwner: Bool
    let subdomain: String
    let type: String
    let iss: String
    let iat: TimeInterval
    let exp: TimeInterval
    
    // Propiedades calculadas para fechas
    var issuedAt: Date { Date(timeIntervalSince1970: iat) }
    var expiresAt: Date { Date(timeIntervalSince1970: exp) }
    
    init?(token: String) {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }

        var base64 = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }

        guard let data = Data(base64Encoded: base64) else { return nil }

        do {
            let decoded = try JSONDecoder().decode(Self.self, from: data)
            self = decoded
        } catch {
            print("Error decoding JWT payload:", error)
            return nil
        }
    }
}
