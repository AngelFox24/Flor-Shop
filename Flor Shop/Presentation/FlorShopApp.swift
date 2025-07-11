import SwiftUI
import FirebaseAuth
import AppRouter

typealias Router = CustomRouter<FlowRoutes, SheetRoutes, AlertRoutes>

@main
struct FlorShopApp: App {
    init() {
        FirebaseApp.configure() // Configura Firebase al inicializar la aplicación
    }
    @State private var router = Router()
    var body: some Scene {
        WindowGroup {
            RootView()
                .withSheetDestinations(router: $router)
                .withAlertDestinations(router: $router)
                .showProgress(router.isLoanding)
                .environment(router)
//                .onOpenURL { url in
//                    let success = router.navigate(to: url)
//                }
        }
    }
}


