import SwiftUI

@main
struct FlorShopApp: App {
    @State private var overlay = OverlayViewModel()
    @State private var session: SessionManager = SessionManagerFactory.getSessionManager()
    init() {
        print("[FlorShopApp] Init.")
        KingfisherConfig.config()
        GoogleSignConfig.config()
    }
    var body: some Scene {
        WindowGroup {
            OverlayContainer {
                VersionCheckView()
            }
            .environment(overlay)
            .environment(session)
        }
    }
}
