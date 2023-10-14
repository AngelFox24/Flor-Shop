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
    @AppStorage("hasShownOnboarding") var hasShownOnboarding: Bool = false
    var body: some View {
            ZStack {
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
                                if logInViewModel.logInStatus == .success {
                                    MenuView(isKeyboardVisible: $isKeyboardVisible)
                                } else {
                                    WelcomeView(isKeyboardVisible: $isKeyboardVisible)
                                }
                            }
                            .onChange(of: logInViewModel.logInStatus, perform: { status in
                                if status == .success {
                                    navManager.popToRoot()
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
            }
        //}
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
        let companyRepository = CompanyRepositoryImpl(manager: companyManager)
        let subsidiaryRepository = SubsidiaryRepositoryImpl(manager: subsidiaryManager)
        let employeeRepository = EmployeeRepositoryImpl(manager: employeeManager)
        let productRepository = ProductRepositoryImpl(manager: productManager)
        let customerRepository = CustomerRepositoryImpl(manager: customerManager)
        let cartRepository = CarRepositoryImpl(manager: cartManager)
        let salesRepository = SaleRepositoryImpl(manager: saleManager)
        
        let logInViewModel = LogInViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, employeeRepository: employeeRepository, cartRepository: cartRepository, productReporsitory: productRepository, saleRepository: salesRepository)
        let registrationViewModel = RegistrationViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, employeeRepository: employeeRepository, cartRepository: cartRepository, productReporsitory: productRepository, saleRepository: salesRepository)
        let customerViewModel = CustomerViewModel(customerRepository: customerRepository)
        let navManager = NavManager()
        MainView()
            .environmentObject(logInViewModel)
            .environmentObject(customerViewModel)
            .environmentObject(VersionCheck())
            .environmentObject(registrationViewModel)
            .environmentObject(navManager)
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
