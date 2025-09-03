import SwiftUI
//import FirebaseAuth

//typealias MainRouter = FlorShopRouter2<FlowRoutes, SheetRoutes, AlertRoutes>
//typealias SessionRouter = FlorShopRouter2<SessionRoutes, SheetRoutes, AlertRoutes>

@main
struct FlorShopApp: App {
    init() {
//        FirebaseApp.configure() // Configura Firebase al inicializar la aplicación
    }
    var body: some Scene {
        WindowGroup {
            VersionCheckView()
        }
    }
}


