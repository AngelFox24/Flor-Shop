import SwiftUI

enum VersionCheckState {
    case iddle
    case loading
    case lockVersion
}

struct VersionCheckView: View {
    //TODO: Get from cloud
    @State private var versionCheck = VersionCheckState.iddle
    var body: some View {
        if case .iddle = versionCheck {
            RootView()
        } else {
            VersionCheckContendView(versionCheck: versionCheck)
        }
    }
}

struct VersionCheckContendView: View {
    var versionCheck: VersionCheckState
    var body: some View {
        switch versionCheck {
        case .loading, .iddle:
            LaunchScreenView()
        case .lockVersion:
            LockScreenView()
        }
    }
}

#Preview {
    VersionCheckView()
}
