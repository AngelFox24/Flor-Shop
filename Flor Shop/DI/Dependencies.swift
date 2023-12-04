//
//  Dependencies.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation
import CoreData

struct Dependencies {
    //Managers
    let mainContext: NSManagedObjectContext
    let companyManager: LocalCompanyManager
    let subsidiaryManager: LocalSubsidiaryManager
    let employeeManager: LocalEmployeeManager
    let customerManager: LocalCustomerManager
    let productManager: LocalProductManager
    let cartManager: LocalCartManager
    let saleManager: LocalSaleManager
    //Repositorios
    let companyRepository: CompanyRepositoryImpl
    let subsidiaryRepository: SubsidiaryRepositoryImpl
    let employeeRepository: EmployeeRepositoryImpl
    let customerRepository: CustomerRepositoryImpl
    let productRepository: ProductRepositoryImpl
    let cartRepository: CarRepositoryImpl
    let salesRepository: SaleRepositoryImpl
    //ViewModels
    let logInViewModel: LogInViewModel
    let registrationViewModel: RegistrationViewModel
    
    let agregarViewModel: AgregarViewModel
    let productsViewModel: ProductViewModel
    let cartViewModel: CartViewModel
    let salesViewModel: SalesViewModel
    let employeeViewModel: EmployeeViewModel
    let customerViewModel: CustomerViewModel
    let companyViewModel: CompanyViewModel
    let addCustomerViewModel: AddCustomerViewModel
    let versionCheck: VersionCheck
    let navManager: NavManager
    
    init() {
        //Managers
        self.mainContext = CoreDataProvider.shared.viewContext
        self.companyManager = LocalCompanyManager(mainContext: mainContext)
        self.subsidiaryManager = LocalSubsidiaryManager(mainContext: mainContext)
        self.employeeManager = LocalEmployeeManager(mainContext: mainContext)
        self.customerManager = LocalCustomerManager(mainContext: mainContext)
        self.productManager = LocalProductManager(mainContext: mainContext)
        self.cartManager = LocalCartManager(mainContext: mainContext)
        self.saleManager = LocalSaleManager(mainContext: mainContext)
        //Repositorios
        self.companyRepository = CompanyRepositoryImpl(manager: companyManager)
        self.subsidiaryRepository = SubsidiaryRepositoryImpl(manager: subsidiaryManager)
        self.employeeRepository = EmployeeRepositoryImpl(manager: employeeManager)
        self.customerRepository = CustomerRepositoryImpl(manager: customerManager)
        self.productRepository = ProductRepositoryImpl(manager: productManager)
        self.cartRepository = CarRepositoryImpl(manager: cartManager)
        self.salesRepository = SaleRepositoryImpl(manager: saleManager)
        //ViewModels
        self.logInViewModel = LogInViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, employeeRepository: employeeRepository, cartRepository: cartRepository, productReporsitory: productRepository, saleRepository: salesRepository, customerRepository: customerRepository)
        self.registrationViewModel = RegistrationViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, employeeRepository: employeeRepository, cartRepository: cartRepository, productReporsitory: productRepository, saleRepository: salesRepository, customerRepository: customerRepository)
        
        self.agregarViewModel = AgregarViewModel(productRepository: productRepository)
        self.productsViewModel = ProductViewModel(productRepository: productRepository)
        self.cartViewModel = CartViewModel(carRepository: cartRepository)
        self.salesViewModel = SalesViewModel(saleRepository: salesRepository)
        self.employeeViewModel = EmployeeViewModel(employeeRepository: employeeRepository)
        self.customerViewModel = CustomerViewModel(customerRepository: customerRepository)
        self.companyViewModel = CompanyViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository)
        self.addCustomerViewModel = AddCustomerViewModel(customerRepository: customerRepository)
        self.versionCheck = VersionCheck()
        self.navManager = NavManager()
    }
}
