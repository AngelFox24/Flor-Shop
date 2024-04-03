//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var versionCheck: VersionCheck
    @EnvironmentObject var logInViewModel: LogInViewModel
    @EnvironmentObject var navManager: NavManager
    @State private var isKeyboardVisible: Bool = false
    @State private var showMenu: Bool = false
    @AppStorage("hasShownOnboarding") var hasShownOnboarding: Bool = false
    @AppStorage("userOrEmail") var userOrEmail: String?
    @AppStorage("password") var password: String?
    var body: some View {
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
                            //Etapa del LogIn o Registro
                            NavigationStack(path: $navManager.navPaths) {
                                ZStack(content: {
                                    if logInViewModel.logInStatus == .success {
                                        MenuView(showMenu: $showMenu, isKeyboardVisible: $isKeyboardVisible)
                                    } else {
                                        WelcomeView(isKeyboardVisible: $isKeyboardVisible)
                                            .onAppear(perform: {
                                                if let user = userOrEmail, let password = password {
                                                    logInViewModel.logInFields.userOrEmail = user
                                                    logInViewModel.logInFields.password = password
                                                    logInViewModel.logIn()
                                                }
                                            })
                                    }
                                })
                                .navigationDestination(for: NavPathsEnum.self, destination: { viewArc in
                                    switch viewArc {
                                    case .loginView:
                                        LogInView(isKeyboardVisible: $isKeyboardVisible)
                                    case .registrationView:
                                        CreateAccountView(isKeyboardVisible: $isKeyboardVisible)
                                    case .customerView:
                                        CustomersView(showMenu: $showMenu, backButton: true)
                                    case .customersForPaymentView:
                                        CustomersView(showMenu: .constant(false), backButton: true)
                                    case .addCustomerView:
                                        AddCustomerView()
                                    case .paymentView:
                                        PaymentView()
                                    case .customerHistoryView:
                                        CustomerHistoryView()
                                    }
                                })
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
                    // checkForPermission()
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                        isKeyboardVisible = true
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        isKeyboardVisible = false
                    }
                }
                if isKeyboardVisible {
                    CustomHideKeyboard()
                    //.padding(.bottom, 12)
                }
            })
        //}
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        //Definimos contexto para todos
        let dependencies = Dependencies()
        MainView()
            .environmentObject(dependencies.logInViewModel)
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.versionCheck)
            .environmentObject(dependencies.registrationViewModel)
            .environmentObject(dependencies.navManager)
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
