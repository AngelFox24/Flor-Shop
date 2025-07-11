//
//  RootView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct RootView: View {
    @State private var versionCheck = VersionViewModel()
    @Environment(Router.self) private var router
    @AppStorage("hasShownOnboarding") var hasShownOnboarding: Bool = false
    private let normalDependencies = NormalDependencies()
    @State private var persistenceSessionConfig = PersistenceSessionConfig()
    var body: some View {
        VStack(spacing: 0) {
            if !hasShownOnboarding {
                OnboardingView()
            } else {
                VersionCheckView()
                    .environment(normalDependencies.logInViewModel)
                    .environment(normalDependencies.registrationViewModel)
                    .environment(persistenceSessionConfig)
            }
        }
        .onAppear {
            //versionCheck.checkAppVersion()
        }
    }
}

#Preview {
    let normalDependencies = NormalDependencies()
    RootView()
        .environment(normalDependencies.logInViewModel)
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
