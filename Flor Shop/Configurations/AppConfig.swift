enum AppConfig {
#if DEBUG
    static let florShopCoreBaseURL = "http://192.168.2.5:8080"
    static let florShopCoreWSBaseURL = "ws://192.168.2.5:8080"
    static let florShopAuthBaseURL = "http://192.168.2.5:8081"
    static let florShopImagesBaseURL = "http://192.168.2.5:8082"
    
    static let bundleID = "MrProFox.FlorShop.dev"
    static let deepLinkScheme = "florshop.dev"
#else
    static let florShopCoreBaseURL = "https://{subdomain}.mrangel.dev"
    static let florShopCoreWSBaseURL = "wss://{subdomain}.mrangel.dev"
    static let florShopAuthBaseURL = "https://auth.mrangel.dev"
    static let florShopImagesBaseURL = "https://images.mrangel.dev"
    
    static let bundleID = "MrProFox.FlorShop"
    static let deepLinkScheme = "florshop"
#endif
}
