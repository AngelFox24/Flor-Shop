enum AppConfig {
#if DEBUG
    static let baseURL = "http://localhost:8080"
    static let wsBaseURL = "wss://pizzarely.mrangel.dev"
#else
    static let baseURL = "https://pizzarely.mrangel.dev"
    static let wsBaseURL = "wss://pizzarely.mrangel.dev"
#endif
}
