import CoreData
import Foundation

@Observable
final class SessionContainer {
    //Session Configuration
    private let sessionConfig: SessionConfig
    //Main Context
    private let mainContext: NSManagedObjectContext
    //Services
    private let imageService: LocalImageService
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
    private let remoteSyncManager: RemoteSyncManager
    //Repositories
    let companyRepository: CompanyRepository
    let subsidiaryRepository: SubsidiaryRepository
    let employeeRepository: EmployeeRepository
    let customerRepository: CustomerRepository
    let productRepository: ProductRepository
    let cartRepository: CarRepository
    let salesRepository: SaleRepository
    let imageRepository: ImageRepository
    let syncRepository: SyncRepository
    init(sessionConfig: SessionConfig) {
        //Session Configuration
        self.sessionConfig = sessionConfig
        self.mainContext = CoreDataProvider.shared.viewContext
        //MARK: Helpers
        self.imageService = LocalImageServiceImpl()
        //MARK: Local Managers
        self.localCompanyManager = LocalCompanyManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localSubsidiaryManager = LocalSubsidiaryManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig, imageService: imageService)
        self.localEmployeeManager = LocalEmployeeManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig, imageService: imageService)
        self.localCustomerManager = LocalCustomerManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig, imageService: imageService)
        self.localProductManager = LocalProductManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig, imageService: imageService)
        self.localCartManager = LocalCartManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig)
        self.localSaleManager = LocalSaleManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig, imageService: imageService)
        self.localImageManager = LocalImageManagerImpl(mainContext: mainContext, sessionConfig: self.sessionConfig, imageService: imageService)
        //MARK: Remote Managers
        self.remoteProductManager = RemoteProductManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteSaleManager = RemoteSaleManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteCompanyManager = RemoteCompanyManagerImpl()
        self.remoteSubsidiaryManager = RemoteSubsidiaryManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteEmployeeManager = RemoteEmployeeManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteCustomerManager = RemoteCustomerManagerImpl(sessionConfig: self.sessionConfig)
        self.remoteSyncManager = RemoteSyncManagerImpl(sessionConfig: self.sessionConfig)
        //MARK: Repositorios
        self.companyRepository = CompanyRepositoryImpl(localManager: localCompanyManager, remoteManager: remoteCompanyManager)
        self.subsidiaryRepository = SubsidiaryRepositoryImpl(localManager: localSubsidiaryManager, remoteManager: remoteSubsidiaryManager)
        self.employeeRepository = EmployeeRepositoryImpl(localManager: localEmployeeManager, remoteManager: remoteEmployeeManager)
        self.customerRepository = CustomerRepositoryImpl(localManager: localCustomerManager, remoteManager: remoteCustomerManager)
        self.productRepository = ProductRepositoryImpl(localManager: localProductManager, remoteManager: remoteProductManager)
        self.cartRepository = CarRepositoryImpl(localManager: localCartManager)
        self.salesRepository = SaleRepositoryImpl(localManager: localSaleManager, remoteManager: remoteSaleManager)
        self.imageRepository = ImageRepositoryImpl(localManager: localImageManager)
        self.syncRepository = SyncRepositoryImpl(remoteSyncManager: remoteSyncManager)
    }
}

extension SessionContainer {
    static var preview: SessionContainer {
        .init(sessionConfig: .init(
            companyId: UUID(),
            subsidiaryId: UUID(),
            employeeId: UUID()
        ))
    }
}
