import Foundation

struct SessionConfig: Codable, Equatable {
    let subdomain: String
    let companyCic: String
    let subsidiaryCic: String
    let employeeCic: String
    static let structName = "SessionConfig"
}
