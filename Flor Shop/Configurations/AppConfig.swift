enum AppConfig {
#if DEBUG
    static let baseURL = "http://192.168.2.5:8080"
    static let wsBaseURL = "ws://192.168.2.5:8080"
#else
    static let baseURL = "https://pizzarely.mrangel.dev"
    static let wsBaseURL = "wss://pizzarely.mrangel.dev"
#endif
}
