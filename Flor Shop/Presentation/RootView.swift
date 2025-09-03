import SwiftUI

struct RootView: View {
    @AppStorage("hasShownOnboarding") var hasShownOnboarding: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            if !hasShownOnboarding {
                OnboardingView()
            } else {
                MainView()
            }
        }
        .onAppear {
            //versionCheck.checkAppVersion()
        }
    }
}

#Preview {
    RootView()
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
