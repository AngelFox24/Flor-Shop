//
//  BusinessDependencies.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation
import CoreData

struct BusinessDependencies {
    //Session Configuration
    let sessionConfig: SessionConfig
    //Main Context
    private let mainContext: NSManagedObjectContext
    //Local Managers
    private let localCompanyManager: LocalCompanyManagerImpl
    private let localSubsidiaryManager: LocalSubsidiaryManagerImpl
    private let localEmployeeManager: LocalEmployeeManagerImpl
    private let localCustomerManager: LocalCustomerManagerImpl
    private let localProductManager: LocalProductManagerImpl
    private let localCartManager: LocalCartManagerImpl
    private let localSaleManager: LocalSaleManagerImpl
    let localImageManager: LocalImageManagerImpl
    //Remote Managers
    private let remoteProductManager: RemoteProductManagerImpl
    private let remoteSaleManager: RemoteSaleManagerImpl
    private let remoteCompanyManager: RemoteCompanyManagerImpl
    private let remoteSubsidiaryManager: RemoteSubsidiaryManagerImpl
    private let remoteEmployeeManager: RemoteEmployeeManagerImpl
    private let remoteCustomerManager: RemoteCustomerManagerImpl
    let remoteImageManager: RemoteImageManagerImpl
    //Repositorios
    private let companyRepository: CompanyRepositoryImpl
    private let subsidiaryRepository: SubsidiaryRepositoryImpl
    private let employeeRepository: EmployeeRepositoryImpl
    private let customerRepository: CustomerRepositoryImpl
    private let productRepository: ProductRepositoryImpl
    private let cartRepository: CarRepositoryImpl
    private let salesRepository: SaleRepositoryImpl
    private let imageRepository: ImageRepositoryImpl
    //UseCases
    private let getSubsidiaryUseCase: GetSubsidiaryUseCase
    private let getCompanyUseCase: GetCompanyUseCase
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
    private let getCustomerSalesUseCase: GetCustomerSalesUseCase
    private let payClientDebtUseCase: PayClientDebtUseCase
    private let deleteUnusedImagesUseCase: DeleteUnusedImagesUseCase
    private let loadSavedImageUseCase: LoadSavedImageUseCase
    private let downloadImageUseCase: DownloadImageUseCase
    private let saveImageUseCase: SaveImageUseCase
    private let exportProductsUseCase: ExportProductsUseCase
    
//    private let registerUserUseCase: RegisterUserUseCase
    private let logInUseCase: LogInUseCase
    private let logOutUseCase: LogOutUseCase
    //ViewModels
    let logInViewModel: LogInViewModel
    let registrationViewModel: RegistrationViewModel
    let agregarViewModel: AgregarViewModel
    let productsViewModel: ProductViewModel
    let cartViewModel: CartViewModel
    let salesViewModel: SalesViewModel
    let employeeViewModel: EmployeeViewModel
    let customerViewModel: CustomerViewModel
    let customerHistoryViewModel: CustomerHistoryViewModel
    //let companyViewModel: CompanyViewModel
    let addCustomerViewModel: AddCustomerViewModel
    
    init(sessionConfig: SessionConfig) {
        //Session Configuration
        self.sessionConfig = sessionConfig
        //MARK: Main Context
        self.mainContext = CoreDataProvider.shared.viewContext
        //MARK: Local Managers
        self.localCompanyManager = LocalCompanyManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localSubsidiaryManager = LocalSubsidiaryManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localEmployeeManager = LocalEmployeeManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localCustomerManager = LocalCustomerManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localProductManager = LocalProductManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localCartManager = LocalCartManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localSaleManager = LocalSaleManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localImageManager = LocalImageManagerImpl(mainContext: mainContext)
        //MARK: Remote Managers
        self.remoteProductManager = RemoteProductManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteSaleManager = RemoteSaleManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteCompanyManager = RemoteCompanyManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.remoteSubsidiaryManager = RemoteSubsidiaryManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.remoteEmployeeManager = RemoteEmployeeManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.remoteCustomerManager = RemoteCustomerManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.remoteImageManager = RemoteImageManagerImpl(mainContext: mainContext)
        //MARK: Repositorios
        self.companyRepository = CompanyRepositoryImpl(localManager: localCompanyManager, remoteManager: remoteCompanyManager)
        self.subsidiaryRepository = SubsidiaryRepositoryImpl(localManager: localSubsidiaryManager, remoteManager: remoteSubsidiaryManager)
        self.employeeRepository = EmployeeRepositoryImpl(localManager: localEmployeeManager, remoteManager: remoteEmployeeManager)
        self.customerRepository = CustomerRepositoryImpl(localManager: localCustomerManager, remoteManager: remoteCustomerManager)
        self.productRepository = ProductRepositoryImpl(localManager: localProductManager, remoteManager: remoteProductManager)
        self.cartRepository = CarRepositoryImpl(localManager: localCartManager)
        self.salesRepository = SaleRepositoryImpl(localManager: localSaleManager, remoteManager: remoteSaleManager)
        self.imageRepository = ImageRepositoryImpl(localManager: localImageManager, remoteManager: remoteImageManager)
        //MARK: UseCases
        self.getSubsidiaryUseCase = GetSubsidiaryInteractor(employeeRepository: employeeRepository)
        self.getCompanyUseCase = GetCompanyInteractor(subsidiaryRepository: subsidiaryRepository)
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
        self.getCustomerSalesUseCase = GetCustomerSalesInteractor(customerRepository: customerRepository)
        self.payClientDebtUseCase = PayClientDebtInteractor(saleRepository: salesRepository)
        self.deleteUnusedImagesUseCase = DeleteUnusedImagesInteractor(imageRepository: imageRepository)
        self.loadSavedImageUseCase = LoadSavedImageInteractor(imageRepository: imageRepository)
        self.downloadImageUseCase = DownloadImageInteractor(imageRepository: imageRepository)
        self.saveImageUseCase = SaveImageInteractor(imageRepository: imageRepository)
        self.exportProductsUseCase = ExportProductsInteractor(productRepository: productRepository)
        
//        self.registerUserUseCase = RegisterUserInteractor(createCompanyUseCase: createCompanyUseCase, createSubsidiaryUseCase: createSubsidiaryUseCase, createEmployeeUseCase: createEmployeeUseCase, setDefaultCompanyUseCase: setDefaultCompanyUseCase, setDefaultSubsidiaryUseCase: setDefaultSubsidiaryUseCase, setDefaultEmployeeUseCase: setDefaultEmployeeUseCase)
        self.logInUseCase = LogInInteractor(
            employeeRepository: employeeRepository,
            setDefaultEmployeeUseCase: setDefaultEmployeeUseCase,
//            setDefaultSubsidiaryUseCase: setDefaultSubsidiaryUseCase,
            setDefaultCompanyUseCase: setDefaultCompanyUseCase,
            getCompanyUseCase: getCompanyUseCase,
            getSubsidiaryUseCase: getSubsidiaryUseCase
        )
        self.logOutUseCase = LogOutInteractor(
            setDefaultEmployeeUseCase: setDefaultEmployeeUseCase,
//            setDefaultSubsidiaryUseCase: setDefaultSubsidiaryUseCase,
            setDefaultCompanyUseCase: setDefaultCompanyUseCase
        )
        //MARK: ViewModels
        self.logInViewModel = LogInViewModel(logInUseCase: logInUseCase, logOutUseCase: logOutUseCase)
        self.registrationViewModel = RegistrationViewModel()
        self.agregarViewModel = AgregarViewModel(saveProductUseCase: saveProductUseCase, loadSavedImageUseCase: loadSavedImageUseCase, saveImageUseCase: saveImageUseCase, exportProductsUseCase: exportProductsUseCase)
        self.productsViewModel = ProductViewModel(getProductsUseCase: getProductsUseCase)
        self.cartViewModel = CartViewModel(getProductsInCartUseCase: getProductsInCartUseCase, getCartUseCase: getCartUseCase, deleteCartDetailUseCase: deleteCartDetailUseCase, addProductoToCartUseCase: addProductoToCartUseCase, emptyCartUseCase: emptyCartUseCase, increaceProductInCartUseCase: increaceProductInCartUseCase, decreaceProductInCartUseCase: decreaceProductInCartUseCase)
        self.salesViewModel = SalesViewModel(registerSaleUseCase: registerSaleUseCase, getSalesUseCase: getSalesUseCase, getSalesDetailsUseCase: getSalesDetailsUseCase)
        self.employeeViewModel = EmployeeViewModel(getEmployeesUseCase: getEmployeesUseCase)
        self.customerViewModel = CustomerViewModel(getCustomersUseCase: getCustomersUseCase)
        self.customerHistoryViewModel = CustomerHistoryViewModel(getCustomerSalesUseCase: getCustomerSalesUseCase, getCustomersUseCase: getCustomersUseCase, payClientDebtUseCase: payClientDebtUseCase)
        //self.companyViewModel = CompanyViewModel(companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository)
        self.addCustomerViewModel = AddCustomerViewModel(saveCustomerUseCase: saveCustomerUseCase, loadSavedImageUseCase: loadSavedImageUseCase, saveImageUseCase: saveImageUseCase)
    }
}
