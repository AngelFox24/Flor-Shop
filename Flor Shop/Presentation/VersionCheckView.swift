import SwiftUI

struct VersionCheckView: View {
    @Environment(Router.self) private var router
    @State private var versionCheck = VersionViewModel()
    var body: some View {
        @Bindable var router = router
        if versionCheck.isSupported {
            NavigationStack(path: $router.path) {
                MainView()
                    .withFlowDestinations()
            }
        } else {
            VersionCheckContendView(versionCheck: versionCheck)
        }
    }
}

struct VersionCheckContendView: View {
    @Bindable var versionCheck: VersionViewModel
    var body: some View {
        switch versionCheck.versionState {
        case .loading:
            LaunchScreenView()
        case .lockVersion:
            LockScreenView()
        }
    }
}

//#Preview {
//    @State var versionCheck = VersionViewModel()
//    @Bindable var versionCheck = versionCheck
//    VersionCheckView(versionCheck: $versionCheck)
//}
