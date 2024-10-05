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
    private let remoteImageManager: RemoteImageManagerImpl
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
    let synchronizerDBUseCase: SynchronizerDBUseCase
    private let getProductsUseCase: GetProductsUseCase
    private let createCompanyUseCase: CreateCompanyUseCase
    private let createSubsidiaryUseCase: CreateSubsidiaryUseCase
    private let createEmployeeUseCase: CreateEmployeeUseCase
    private let saveProductUseCase: SaveProductUseCase
    private let getCartUseCase: GetCartUseCase
    private let deleteCartDetailUseCase: DeleteCartDetailUseCase
    private let addProductoToCartUseCase: AddProductoToCartUseCase
    private let emptyCartUseCase: EmptyCartUseCase
    private let changeProductAmountInCartUseCase: ChangeProductAmountInCartUseCase
    private let registerSaleUseCase: RegisterSaleUseCase
    private let getSalesUseCase: GetSalesUseCase
    private let getEmployeesUseCase: GetEmployeesUseCase
    private let getCustomersUseCase: GetCustomersUseCase
    private let saveCustomerUseCase: SaveCustomerUseCase
    private let getSalesDetailsUseCase: GetSalesDetailsUseCase
    private let getCustomerSalesUseCase: GetCustomerSalesUseCase
    private let payClientDebtUseCase: PayClientDebtUseCase
    private let deleteUnusedImagesUseCase: DeleteUnusedImagesUseCase
    private let saveImageUseCase: SaveImageUseCase
    private let exportProductsUseCase: ExportProductsUseCase
    private let importProductsUseCase: ImportProductsUseCase
//    private let logInUseCase: LogInUseCase
//    private let logOutUseCase: LogOutUseCase
//    let logInViewModel: LogInViewModel
//    let registrationViewModel: RegistrationViewModel
    let agregarViewModel: AgregarViewModel
    let productsViewModel: ProductViewModel
    let cartViewModel: CartViewModel
    let salesViewModel: SalesViewModel
    let employeeViewModel: EmployeeViewModel
    let customerViewModel: CustomerViewModel
    let customerHistoryViewModel: CustomerHistoryViewModel
    let addCustomerViewModel: AddCustomerViewModel
    
    init(sessionConfig: SessionConfig) {
        //Session Configuration
        self.sessionConfig = sessionConfig
        self.mainContext = CoreDataProvider.shared.viewContext
        //MARK: Local Managers
        self.localCompanyManager = LocalCompanyManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localSubsidiaryManager = LocalSubsidiaryManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localEmployeeManager = LocalEmployeeManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localCustomerManager = LocalCustomerManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localProductManager = LocalProductManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localCartManager = LocalCartManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localSaleManager = LocalSaleManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localImageManager = LocalImageManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        //MARK: Remote Managers
        self.remoteProductManager = RemoteProductManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteSaleManager = RemoteSaleManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteCompanyManager = RemoteCompanyManagerImpl()
        self.remoteSubsidiaryManager = RemoteSubsidiaryManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteEmployeeManager = RemoteEmployeeManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteCustomerManager = RemoteCustomerManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteImageManager = RemoteImageManagerImpl()
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
        self.synchronizerDBUseCase = SynchronizerDBInteractor(persistentContainer: CoreDataProvider.shared.persistContainer, imageRepository: imageRepository, companyRepository: companyRepository, subsidiaryRepository: subsidiaryRepository, customerRepository: customerRepository, employeeRepository: employeeRepository, productRepository: productRepository, saleRepository: salesRepository)
        self.getProductsUseCase = GetProductInteractor(productRepository: productRepository)
        self.createCompanyUseCase = CreateCompanyInteractor(companyRepository: companyRepository)
        self.createSubsidiaryUseCase = CreateSubsidiaryInteractor(subsidiaryRepository: subsidiaryRepository)
        self.createEmployeeUseCase = CreateEmployeeInteractor(synchronizerDBUseCase: synchronizerDBUseCase, employeeRepository: employeeRepository, imageRepository: imageRepository)
        self.saveProductUseCase = SaveProductInteractor(synchronizerDBUseCase: synchronizerDBUseCase, productRepository: productRepository, imageRepository: imageRepository)
        self.getCartUseCase = GetCartInteractor(cartRepository: cartRepository)
        self.deleteCartDetailUseCase = DeleteCartDetailInteractor(cartRepository: cartRepository)
        self.addProductoToCartUseCase = AddProductoToCartInteractor(cartRepository: cartRepository)
        self.emptyCartUseCase = EmptyCartInteractor(cartRepository: cartRepository)
        self.changeProductAmountInCartUseCase = ChangeProductAmountInCartInteractor(cartRepository: cartRepository)
        self.registerSaleUseCase = RegisterSaleInteractor(synchronizerDBUseCase: synchronizerDBUseCase, saleRepository: salesRepository)
        self.getSalesUseCase = GetSalesInteractor(saleRepository: salesRepository)
        self.getEmployeesUseCase = GetEmployeesUseCaseInteractor(employeeRepository: employeeRepository)
        self.getCustomersUseCase = GetCustomersInteractor(customerRepository: customerRepository)
        self.saveCustomerUseCase = SaveCustomerInteractor(synchronizerDBUseCase: synchronizerDBUseCase, customerRepository: customerRepository, imageRepository: imageRepository)
        self.getSalesDetailsUseCase = GetSalesDetailsInteractor(saleRepository: salesRepository)
        self.getCustomerSalesUseCase = GetCustomerSalesInteractor(customerRepository: customerRepository)
        self.payClientDebtUseCase = PayClientDebtInteractor(synchronizerDBUseCase: synchronizerDBUseCase, customerRepository: customerRepository)
        self.deleteUnusedImagesUseCase = DeleteUnusedImagesInteractor(imageRepository: imageRepository)
        self.saveImageUseCase = SaveImageInteractor(imageRepository: imageRepository)
        self.exportProductsUseCase = ExportProductsInteractor(productRepository: productRepository)
        self.importProductsUseCase = ImportProductsInteractor(imageRepository: imageRepository, productRepository: productRepository)
//        self.logInUseCase = LogInInteractor(sessionRepository: ses)
//        self.logOutUseCase = LogOutInteractor()
        //MARK: ViewModels
//        self.logInViewModel = LogInViewModel(logInUseCase: logInUseCase, logOutUseCase: logOutUseCase)
//        self.registrationViewModel = RegistrationViewModel()
        self.agregarViewModel = AgregarViewModel(saveProductUseCase: saveProductUseCase, saveImageUseCase: saveImageUseCase, exportProductsUseCase: exportProductsUseCase, importProductsUseCase: importProductsUseCase)
        self.productsViewModel = ProductViewModel(synchronizerDBUseCase: synchronizerDBUseCase, getProductsUseCase: getProductsUseCase)
        self.cartViewModel = CartViewModel(getCartUseCase: getCartUseCase, deleteCartDetailUseCase: deleteCartDetailUseCase, addProductoToCartUseCase: addProductoToCartUseCase, emptyCartUseCase: emptyCartUseCase, changeProductAmountInCartUseCase: changeProductAmountInCartUseCase)
        self.salesViewModel = SalesViewModel(registerSaleUseCase: registerSaleUseCase, getSalesUseCase: getSalesUseCase, getSalesDetailsUseCase: getSalesDetailsUseCase)
        self.employeeViewModel = EmployeeViewModel(getEmployeesUseCase: getEmployeesUseCase)
        self.customerViewModel = CustomerViewModel(getCustomersUseCase: getCustomersUseCase)
        self.customerHistoryViewModel = CustomerHistoryViewModel(getCustomerSalesUseCase: getCustomerSalesUseCase, getCustomersUseCase: getCustomersUseCase, payClientDebtUseCase: payClientDebtUseCase)
        self.addCustomerViewModel = AddCustomerViewModel(saveCustomerUseCase: saveCustomerUseCase, saveImageUseCase: saveImageUseCase)
    }
}
