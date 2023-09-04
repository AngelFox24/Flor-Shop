//
//  Flor_ShopApp.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI
import CoreData
import Firebase

@main
struct FlorShopApp: App {
    init() {
        FirebaseApp.configure() // Configura Firebase al inicializar la aplicación
    }
    var body: some Scene {
        WindowGroup {
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
            let customerRepository = CustomerRepositoryImpl(manager: customerManager)
            let productRepository = ProductRepositoryImpl(manager: productManager)
            let cartRepository = CarRepositoryImpl(manager: cartManager)
            let salesRepository = SaleRepositoryImpl(manager: saleManager)
            //ViewModels
            let logInViewModel = LogInViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, employeeRepository: employeeRepository, cartRepository: cartRepository, productReporsitory: productRepository)
            let registrationViewModel = RegistrationViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, employeeRepository: employeeRepository, cartRepository: cartRepository, productReporsitory: productRepository)
            
            let agregarViewModel = AgregarViewModel(productRepository: productRepository)
            let productsViewModel = ProductViewModel(productRepository: productRepository)
            let cartViewModel = CartViewModel(carRepository: cartRepository)
            let salesViewModel = SalesViewModel(saleRepository: salesRepository)
            let companyViewModel = CompanyViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository)
            let versionCheck = VersionCheck()
            MainView()
                .environmentObject(logInViewModel)
                .environmentObject(registrationViewModel)
                .environmentObject(agregarViewModel)
                .environmentObject(productsViewModel)
                .environmentObject(cartViewModel)
                .environmentObject(salesViewModel)
                .environmentObject(versionCheck)
                .environmentObject(companyViewModel)
        }
    }
}
