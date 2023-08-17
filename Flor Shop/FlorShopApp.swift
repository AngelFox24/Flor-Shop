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
            let managerEntityManager = LocalManagerEntityManager(mainContext: CoreDataProvider.shared.viewContext)
            let companyManager = LocalCompanyManager(mainContext: CoreDataProvider.shared.viewContext)
            let subsidiaryManager = LocalSubsidiaryManager(mainContext: CoreDataProvider.shared.viewContext)
            let employeeManager = LocalEmployeeManager(mainContext: CoreDataProvider.shared.viewContext)
            let customerManager = LocalCustomerManager(mainContext: CoreDataProvider.shared.viewContext)
            let productManager = LocalProductManager(mainContext: CoreDataProvider.shared.viewContext)
            let cartManager = LocalCarManager(mainContext: CoreDataProvider.shared.viewContext)
            let saleManager = LocalSaleManager(mainContext: CoreDataProvider.shared.viewContext)
            //Repositorios
            let managerRepository = ManagerRepositoryImpl(manager: managerEntityManager)
            let companyRepository = CompanyRepositoryImpl(manager: companyManager)
            let subsidiaryRepository = SubsidiaryRepositoryImpl(manager: subsidiaryManager)
            let employeeRepository = EmployeeRepositoryImpl(manager: employeeManager)
            let customerRepository = CustomerRepositoryImpl(manager: customerManager)
            let productRepository = ProductRepositoryImpl(manager: productManager)
            let cartRepository = CarRepositoryImpl(manager: cartManager)
            let salesRepository = SaleRepositoryImpl(manager: saleManager)
            //ViewModels
            let productsCoreData = ProductViewModel(productRepository: productRepository)
            let cartCoreData = CartViewModel(carRepository: cartRepository)
            let salesCoreData = SalesViewModel(saleRepository: salesRepository)
            let companyCoreData = CompanyViewModel(managerRepository: managerRepository, companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository)
            let versionCheck = VersionCheck()
            MenuView()
                .environmentObject(productsCoreData)
                .environmentObject(cartCoreData)
                .environmentObject(salesCoreData)
                .environmentObject(versionCheck)
                .environmentObject(companyCoreData)
        }
    }
}
