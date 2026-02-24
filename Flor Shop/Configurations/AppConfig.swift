import Foundation

enum AppConfig {
    private static let infoDict: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist not found")
        }
        return dict
    }()
    static let florShopCoreBaseURL: String = {
        guard let url = AppConfig.infoDict["FLORSHOP_CORE_BASE_URL"] as? String else {
            fatalError("FLORSHOP_CORE_BASE_URL not found")
        }
        return url
    }()
    static let florShopAuthBaseURL: String = {
        guard let url = AppConfig.infoDict["FLORSHOP_AUTH_BASE_URL"] as? String else {
            fatalError("FLORSHOP_AUTH_BASE_URL not found")
        }
        return url
    }()
    static let florShopImagesBaseURL: String = {
        guard let url = AppConfig.infoDict["FLORSHOP_IMAGES_BASE_URL"] as? String else {
            fatalError("FLORSHOP_IMAGES_BASE_URL not found")
        }
        return url
    }()
    static let powerSyncWS: String = {
        guard let url = AppConfig.infoDict["FLORSHOP_SYNC_WS"] as? String else {
            fatalError("FLORSHOP_SYNC_WS not found")
        }
        return url
    }()
    static let florShopPlatformBaseURL: String = {
        guard let url = AppConfig.infoDict["FLORSHOP_PLATFORM_BASE_URL"] as? String else {
            fatalError("FLORSHOP_PLATFORM_BASE_URL not found")
        }
        return url
    }()
    static let bundleID: String = {
        guard let id = Bundle.main.bundleIdentifier else {
            fatalError("Bundle identifier not found")
        }
        return id
    }()
    static let deepLinkScheme: String = {
        guard let scheme = infoDict["DEEP_LINK_SCHEME"] as? String else {
            fatalError("DEEP_LINK_SCHEME not found")
        }
        return scheme
    }()
}
