//
//  RootView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct RootView: View {
    @State var sesConfig: SessionConfig? = nil
    @EnvironmentObject var loadingState: LoadingState
    @EnvironmentObject var versionCheck: VersionCheck
    @EnvironmentObject var navManager: NavManager
    
    @EnvironmentObject var logInViewModel: LogInViewModel
//    @EnvironmentObject var registrationViewModel: RegistrationViewModel
    @EnvironmentObject var errorState: ErrorState
    
    @State private var isKeyboardVisible: Bool = false
    
    @AppStorage("hasShownOnboarding") var hasShownOnboarding: Bool = false
    @AppStorage("userOrEmail") var userOrEmail: String?
    @AppStorage("password") var password: String?
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
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
                                ZStack(content: {
                                    if logInViewModel.logInStatus == .success, let sesC = sesConfig {
                                        let sesDep = BusinessDependencies(sessionConfig: sesC)
                                        MainView(isKeyboardVisible: $isKeyboardVisible, dependencies: sesDep)
                                    } else {
                                        WelcomeView(isKeyboardVisible: $isKeyboardVisible)
                                            .onAppear(perform: {
                                                logIn()
                                            })
                                    }
                                })
                                .navigationDestination(for: SessionRoutes.self) { route in
                                    switch route {
                                    case .loginView:
                                        LogInView(isKeyboardVisible: $isKeyboardVisible, sesConfig: $sesConfig)
                                    case .registrationView:
                                        LogInView(isKeyboardVisible: $isKeyboardVisible, sesConfig: $sesConfig)
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
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                        isKeyboardVisible = true
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        isKeyboardVisible = false
                    }
                }
                if isKeyboardVisible {
                    CustomHideKeyboard()
                }
            })
            if loadingState.isLoading {
                LoadingView()
            }
        }
        .onAppear(perform: {
            print("Var: \(loadingState.isLoading)")
        })
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
            .environmentObject(normalDependencies.loadingState)
            .environmentObject(normalDependencies.versionCheck)
            .environmentObject(normalDependencies.logInViewModel)
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
