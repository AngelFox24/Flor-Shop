import SwiftUI

struct VersionCheckView: View {
    @State private var versionCheck = VersionViewModel()
    var body: some View {
        if versionCheck.isSupported {
            RootView()
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

#Preview {
    VersionCheckView()
}
