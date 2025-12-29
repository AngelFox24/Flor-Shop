import SwiftUI

@main
struct FlorShopApp: App {
    @State private var overlay = OverlayViewModel()
    init() {
        KingfisherConfig.config()
        GoogleSignConfig.config()
    }
    var body: some Scene {
        WindowGroup {
            OverlayContainer {
                VersionCheckView()
            }
            .environment(overlay)
        }
    }
}
