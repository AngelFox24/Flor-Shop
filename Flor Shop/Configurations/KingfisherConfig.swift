import Kingfisher

enum KingfisherConfig {
    static func config() {
        let cache = ImageCache.default
        
        // Memoria
        cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        cache.memoryStorage.config.countLimit = 100
        cache.memoryStorage.config.expiration = .seconds(60 * 10)
        
        // Disco
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
        cache.diskStorage.config.expiration = .never
        
        // Concurrencia
        KingfisherManager.shared.downloader.sessionConfiguration
            .httpMaximumConnectionsPerHost = 8
    }
}
