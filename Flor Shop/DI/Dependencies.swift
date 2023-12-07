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
    private let mainContext: NSManagedObjectContext
    private let companyManager: LocalCompanyManager
    private let subsidiaryManager: LocalSubsidiaryManager
    private let employeeManager: LocalEmployeeManager
    private let customerManager: LocalCustomerManager
    private let productManager: LocalProductManager
    private let cartManager: LocalCartManager
    private let saleManager: LocalSaleManager
    //Repositorios
    private let companyRepository: CompanyRepositoryImpl
    private let subsidiaryRepository: SubsidiaryRepositoryImpl
    private let employeeRepository: EmployeeRepositoryImpl
    private let customerRepository: CustomerRepositoryImpl
    private let productRepository: ProductRepositoryImpl
    private let cartRepository: CarRepositoryImpl
    private let salesRepository: SaleRepositoryImpl
    //UseCases
    private let getSubsidiaryUseCase: GetSubsidiaryUseCase
    private let getCompanyUseCase: GetCompanyUseCase
    private let setDefaultCompanyUseCase: SetDefaultCompanyUseCase
    private let setDefaultSubsidiaryUseCase: SetDefaultSubsidiaryUseCase
    private let setDefaultEmployeeUseCase: SetDefaultEmployeeUseCase
    private let getProductsUseCase: GetProductsUseCase
    private let createCompanyUseCase: CreateCompanyUseCase
    private let createSubsidiaryUseCase: CreateSubsidiaryUseCase
    private let createEmployeeUseCase: CreateEmployeeUseCase
    private let saveProductUseCase: SaveProductUseCase
    private let getProductsInCartUseCase: GetProductsInCartUseCase
    private let getCartUseCase: GetCartUseCase
    private let deleteCartDetailUseCase: DeleteCartDetailUseCase
    private let addProductoToCartUseCase: AddProductoToCartUseCase
    private let emptyCartUseCase: EmptyCartUseCase
    private let increaceProductInCartUseCase: IncreaceProductInCartUseCase
    private let decreaceProductInCartUseCase: DecreaceProductInCartUseCase
    private let registerSaleUseCase: RegisterSaleUseCase
    private let getSalesUseCase: GetSalesUseCase
    private let getEmployeesUseCase: GetEmployeesUseCase
    private let getCustomersUseCase: GetCustomersUseCase
    private let saveCustomerUseCase: SaveCustomerUseCase
    private let getSalesDetailsUseCase: GetSalesDetailsUseCase
    
    private let registerUserUseCase: RegisterUserUseCase
    private let logInUseCase: LogInUseCase
    //ViewModels
    let logInViewModel: LogInViewModel
    let registrationViewModel: RegistrationViewModel
    let agregarViewModel: AgregarViewModel
    let productsViewModel: ProductViewModel
    let cartViewModel: CartViewModel
    let salesViewModel: SalesViewModel
    let employeeViewModel: EmployeeViewModel
    let customerViewModel: CustomerViewModel
    //let companyViewModel: CompanyViewModel
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
        //MARK: Repositorios
        self.companyRepository = CompanyRepositoryImpl(manager: companyManager)
        self.subsidiaryRepository = SubsidiaryRepositoryImpl(manager: subsidiaryManager)
        self.employeeRepository = EmployeeRepositoryImpl(manager: employeeManager)
        self.customerRepository = CustomerRepositoryImpl(manager: customerManager)
        self.productRepository = ProductRepositoryImpl(manager: productManager)
        self.cartRepository = CarRepositoryImpl(manager: cartManager)
        self.salesRepository = SaleRepositoryImpl(manager: saleManager)
        //MARK: UseCases
        self.getSubsidiaryUseCase = GetSubsidiaryInteractor(employeeRepository: employeeRepository)
        self.getCompanyUseCase = GetCompanyInteractor(subsidiaryRepository: subsidiaryRepository)
        self.setDefaultCompanyUseCase = SetDefaultCompanyInteractor(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, customerRepository: customerRepository)
        self.setDefaultSubsidiaryUseCase = SetDefaultSubsidiaryInteractor(productReporsitory: productRepository, employeeRepository: employeeRepository, saleRepository: salesRepository)
        self.setDefaultEmployeeUseCase = SetDefaultEmployeeInteractor(cartRepository: cartRepository)
        self.getProductsUseCase = GetProductInteractor(productRepository: productRepository)
        self.createCompanyUseCase = CreateCompanyInteractor(companyRepository: companyRepository)
        self.createSubsidiaryUseCase = CreateSubsidiaryInteractor(subsidiaryRepository: subsidiaryRepository)
        self.createEmployeeUseCase = CreateEmployeeInteractor(employeeRepository: employeeRepository)
        self.saveProductUseCase = SaveProductInteractor(productRepository: productRepository)
        self.getProductsInCartUseCase = GetProductsInCartInteractor(cartRepository: cartRepository)
        self.getCartUseCase = GetCartInteractor(cartRepository: cartRepository)
        self.deleteCartDetailUseCase = DeleteCartDetailInteractor(cartRepository: cartRepository)
        self.addProductoToCartUseCase = AddProductoToCartInteractor(cartRepository: cartRepository)
        self.emptyCartUseCase = EmptyCartInteractor(cartRepository: cartRepository)
        self.increaceProductInCartUseCase = IncreaceProductInCartInteractor(cartRepository: cartRepository)
        self.decreaceProductInCartUseCase = DecreaceProductInCartInteractor(cartRepository: cartRepository)
        self.registerSaleUseCase = RegisterSaleInteractor(saleRepository: salesRepository)
        self.getSalesUseCase = GetSalesInteractor(saleRepository: salesRepository)
        self.getEmployeesUseCase = GetEmployeesUseCaseInteractor(employeeRepository: employeeRepository)
        self.getCustomersUseCase = GetCustomersInteractor(customerRepository: customerRepository)
        self.saveCustomerUseCase = SaveCustomerInteractor(customerRepository: customerRepository)
        self.getSalesDetailsUseCase = GetSalesDetailsInteractor(saleRepository: salesRepository)
        
        self.registerUserUseCase = RegisterUserInteractor(createCompanyUseCase: createCompanyUseCase, createSubsidiaryUseCase: createSubsidiaryUseCase, createEmployeeUseCase: createEmployeeUseCase, setDefaultCompanyUseCase: setDefaultCompanyUseCase, setDefaultSubsidiaryUseCase: setDefaultSubsidiaryUseCase, setDefaultEmployeeUseCase: setDefaultEmployeeUseCase)
        self.logInUseCase = LogInInteractor(employeeRepository: employeeRepository, setDefaultEmployeeUseCase: setDefaultEmployeeUseCase, setDefaultSubsidiaryUseCase: setDefaultSubsidiaryUseCase, setDefaultCompanyUseCase: setDefaultCompanyUseCase, getCompanyUseCase: getCompanyUseCase, getSubsidiaryUseCase: getSubsidiaryUseCase)
        //MARK: ViewModels
        self.logInViewModel = LogInViewModel(logInUseCase: logInUseCase)
        self.registrationViewModel = RegistrationViewModel(registerUserUseCase: registerUserUseCase)
        self.agregarViewModel = AgregarViewModel(saveProductUseCase: saveProductUseCase)
        self.productsViewModel = ProductViewModel(getProductsUseCase: getProductsUseCase)
        self.cartViewModel = CartViewModel(getProductsInCartUseCase: getProductsInCartUseCase, getCartUseCase: getCartUseCase, deleteCartDetailUseCase: deleteCartDetailUseCase, addProductoToCartUseCase: addProductoToCartUseCase, emptyCartUseCase: emptyCartUseCase, increaceProductInCartUseCase: increaceProductInCartUseCase, decreaceProductInCartUseCase: decreaceProductInCartUseCase)
        self.salesViewModel = SalesViewModel(registerSaleUseCase: registerSaleUseCase, getSalesUseCase: getSalesUseCase, getSalesDetailsUseCase: getSalesDetailsUseCase)
        self.employeeViewModel = EmployeeViewModel(getEmployeesUseCase: getEmployeesUseCase)
        self.customerViewModel = CustomerViewModel(getCustomersUseCase: getCustomersUseCase)
        //self.companyViewModel = CompanyViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository)
        self.addCustomerViewModel = AddCustomerViewModel(saveCustomerUseCase: saveCustomerUseCase)
        self.versionCheck = VersionCheck()
        self.navManager = NavManager()
    }
}
