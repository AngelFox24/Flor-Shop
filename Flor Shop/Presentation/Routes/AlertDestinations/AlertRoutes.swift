import AppRouter

enum AlertRoutes: AlertType {
    case error(_ error: String)
    case wsError
    
    var id: Int { hashValue }
}
