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
    @State private var isKeyboardVisible: Bool = false
    @AppStorage("hasShownOnboarding") var hasShownOnboarding: Bool = false
    var body: some View {
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
                    if logInViewModel.logInStatus == .success {
                        MenuView(isKeyboardVisible: $isKeyboardVisible)
                    } else {
                        NavigationView(content: {
                            VStack(content: {
                                WelcomeView(isKeyboardVisible: $isKeyboardVisible)
                            })
                        })
                    }
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        //Definimos contexto para todos
        let companyManager = LocalCompanyManager(mainContext: CoreDataProvider.shared.viewContext)
        let subsidiaryManager = LocalSubsidiaryManager(mainContext: CoreDataProvider.shared.viewContext)
        let employeeManager = LocalEmployeeManager(mainContext: CoreDataProvider.shared.viewContext)
        let customerManager = LocalCustomerManager(mainContext: CoreDataProvider.shared.viewContext)
        let productManager = LocalProductManager(mainContext: CoreDataProvider.shared.viewContext)
        let cartManager = LocalCartManager(mainContext: CoreDataProvider.shared.viewContext)
        let saleManager = LocalSaleManager(mainContext: CoreDataProvider.shared.viewContext)
        //Repositorios
        let companyRepository = CompanyRepositoryImpl(companyManager: companyManager)
        let subsidiaryRepository = SubsidiaryRepositoryImpl(manager: subsidiaryManager)
        let employeeRepository = EmployeeRepositoryImpl(manager: employeeManager)
        let productRepository = ProductRepositoryImpl(manager: productManager)
        let cartRepository = CarRepositoryImpl(manager: cartManager)
        
        let logInViewModel = LogInViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, employeeRepository: employeeRepository, cartRepository: cartRepository, productReporsitory: productRepository)
        let registrationViewModel = RegistrationViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, employeeRepository: employeeRepository, cartRepository: cartRepository, productReporsitory: productRepository)
        MainView()
            .environmentObject(logInViewModel)
            .environmentObject(VersionCheck())
            .environmentObject(registrationViewModel)
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
