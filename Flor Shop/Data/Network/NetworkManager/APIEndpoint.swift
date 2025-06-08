import Foundation
enum APIEndpoint {
    enum Session {
        static let base = "/session"
        static let login = base + "/logIn"
    }
    enum Sync {
        static let base = "/verifySync"
        static let webSocekt = base + "/ws"
    }
    enum Company {
        static let base = "/companies"
        static let sync = base + "/sync"
    }
    enum Subsidiary {
        static let base = "/subsidiaries"
        static let sync = base + "/sync"
    }
    enum Customer {
        static let base = "/customers"
        static let payDebt = base + "/payDebt"
        static let sync = base + "/sync"
    }
    enum Employee {
        static let base = "/employees"
        static let sync = base + "/sync"
    }
    enum Product {
        static let base = "/products"
        static let sync = base + "/sync"
    }
    enum Sale {
        static let base = "/sales"
        static let sync = base + "/sync"
    }
    enum ImageUrls {
        static let base = "/imageUrls"
        static let sync = base + "/sync"
    }
}
