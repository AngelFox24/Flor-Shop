//
//  RootView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct RootView: View {
//    @State var sesConfig: SessionConfig? = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
    @State var sesConfig: SessionConfig? = nil
    @EnvironmentObject var versionCheck: VersionCheck
    @EnvironmentObject var navManager: NavManager
    
    @EnvironmentObject var logInViewModel: LogInViewModel
    @EnvironmentObject var errorState: ErrorState
    
    @EnvironmentObject var viewStates: ViewStates
    
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
                                VStack(content: {
                                    if logInViewModel.logInStatus == .success, let sesC = sesConfig {
                                        let sesDep = BusinessDependencies(sessionConfig: sesC)
                                        MainView(dependencies: sesDep)
                                    } else {
                                        WelcomeView()
                                            .onAppear {
                                                logIn()
                                            }
                                    }
                                })
                                .navigationDestination(for: SessionRoutes.self) { route in
                                    switch route {
                                    case .loginView:
                                        LogInView(logInFields: logInViewModel.logInFields, sesConfig: $sesConfig)
                                    case .registrationView:
                                        let dependencies: BusinessDependencies = BusinessDependencies(sessionConfig: SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID()))
                                        AgregarView(selectedTab: .constant(.plus))
                                            .environmentObject(dependencies.agregarViewModel)
//                                        CreateAccountView(isKeyboardVisible: $isKeyboardVisible)
                                    }
                                }
                            }
                            .onChange(of: logInViewModel.logInStatus, perform: { status in
                                if status == .success {
                                    navManager.popToRoot()
                                    userOrEmail = logInViewModel.logInFields.userOrEmail
                                    password = logInViewModel.logInFields.password
                                }
                            })
                        case .unowned:
                            LockScreenView()
                        }
                    }
                }
                .onAppear {
                    //versionCheck.checkAppVersion()
                }
            }
            if viewStates.isLoading {
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
        if let user = userOrEmail, let password = password {
            logInViewModel.logInFields.userOrEmail = user
            logInViewModel.logInFields.password = password
            Task {
                print("Se logea desde guardado")
                let ses = try await logInViewModel.logIn()
                await MainActor.run {
                    self.sesConfig = ses
                    logInViewModel.logInStatus = .success
                }
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
        //Definimos contexto para todos
        let normalDependencies = NormalDependencies()
        RootView()
            .environmentObject(normalDependencies.navManager)
            .environmentObject(normalDependencies.versionCheck)
            .environmentObject(normalDependencies.logInViewModel)
            .environmentObject(normalDependencies.viewStates)
            .environmentObject(normalDependencies.errorState)
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
