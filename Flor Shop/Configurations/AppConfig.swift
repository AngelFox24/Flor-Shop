enum AppConfig {
#if DEBUG
    static let baseURL = "http://192.168.2.5:8080"
    static let wsBaseURL = "ws://192.168.2.5:8080"
    static let bundleID = "MrProFox.FlorShop.dev"
    static let deepLinkScheme: String = "florshop.dev"
#else
    static let baseURL = "https://pizzarely.mrangel.dev"
    static let wsBaseURL = "wss://pizzarely.mrangel.dev"
    static let bundleID = "MrProFox.FlorShop"
    static let deepLinkScheme: String = "florshop"
#endif
}
