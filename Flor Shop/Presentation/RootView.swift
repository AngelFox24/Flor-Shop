//
//  RootView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var versionCheck: VersionCheck
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var logInViewModel: LogInViewModel
    @EnvironmentObject var errorState: ErrorState
    
    @State var loading: Bool = false
    
    @AppStorage("hasShownOnboarding") var hasShownOnboarding: Bool = false
    @AppStorage("userOrEmail") var userOrEmail: String?
    @AppStorage("password") var password: String?
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    if !hasShownOnboarding {
                        OnboardingView(onAction: {
                            hasShownOnboarding = true
                        })
                    } else {
                        switch versionCheck.versionIsOk {
                        case .loading:
                            LaunchScreenView()
                        case .lockVersion:
                            LockScreenView()
                        case .versionOk:
                            NavigationStack(path: $navManager.navPaths) {
                                VStack {
                                    if let sesDep = logInViewModel.businessDependencies {
                                        MainView(dependencies: sesDep, loading: $loading)
                                    } else {
                                        WelcomeView()
                                            .onAppear {
                                                logIn()
                                            }
                                    }
                                }
                                .navigationDestination(for: SessionRoutes.self) { route in
                                    switch route {
                                    case .loginView:
                                        LogInView(loading: $loading)
                                    case .registrationView:
                                        LogInView(loading: $loading)
                                    }
                                }
                            }
                        case .unowned:
                            LockScreenView()
                        }
                    }
                }
                .onAppear {
                    //versionCheck.checkAppVersion()
                }
            }
            if loading {
                LoadingView()
            }
        }
        .onChange(of: errorState.isPresented, perform: { item in
            if !errorState.isPresented {
                errorState.error = ""
            }
        })
        .alert(errorState.error, isPresented: $errorState.isPresented, actions: {})
    }
    private func logIn() {
        if let user = userOrEmail, let pass = password {
            logInViewModel.logInFields.userOrEmail = user
            logInViewModel.logInFields.password = pass
            Task {
                loading = true
                print("Se logea desde guardado")
                let ses = try await logInViewModel.logIn()
                await MainActor.run {
                    self.userOrEmail = logInViewModel.logInFields.userOrEmail
                    self.password = logInViewModel.logInFields.password
                    self.logInViewModel.businessDependencies = BusinessDependencies(sessionConfig: ses)
                    navManager.popToRoot()
                }
                loading = false
            }
        }
//                                                else {//Registration not work yet
//                                                    let reg = registrationViewModel.registerUser()
//                                                    print("\(reg)")
//                                                    logInViewModel.logInFields.userOrEmail = registrationViewModel.registrationFields.email
//                                                    logInViewModel.logInFields.password = registrationViewModel.registrationFields.password
//                                                    print("User: \(registrationViewModel.registrationFields.email)")
//                                                    print("Pass: \(registrationViewModel.registrationFields.password)")
//                                                    sesConfig = logInViewModel.logIn()
//                                                }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let normalDependencies = NormalDependencies()
        RootView()
            .environmentObject(normalDependencies.navManager)
            .environmentObject(normalDependencies.versionCheck)
            .environmentObject(normalDependencies.logInViewModel)
            .environmentObject(normalDependencies.errorState)
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
