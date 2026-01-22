import Foundation

@Observable
final class SessionContainer {
    //Session Config
    let session: SessionConfig
    //Services
    private let fileManager: LocalImageFileManager
    //Local Managers
    private let localImageManager: LocalImageManagerImpl
    private let sqlLiteSubsidiaryManager: SQLiteSubsidiaryManager
    private let sqlLiteEmployeeManager: SQLiteEmployeeManager
    private let sqlLiteCustomerManager: LocalCustomerManager
    private let sqlLiteProductManager: LocalProductManager
    private let sqlLiteCartManager: LocalCartManager
    private let sqlLiteSaleManager: LocalSaleManager
    //Remote Managers
    private let remoteImageManager: RemoteImageManagerImpl
    private let remoteProductManager: RemoteProductManagerImpl
    private let remoteSaleManager: RemoteSaleManagerImpl
    private let remoteCompanyManager: RemoteCompanyManagerImpl
    private let remoteSubsidiaryManager: RemoteSubsidiaryManagerImpl
    private let remoteEmployeeManager: RemoteEmployeeManagerImpl
    private let remoteCustomerManager: RemoteCustomerManagerImpl
    //Repositories
    let companyRepository: CompanyRepository
    let subsidiaryRepository: SubsidiaryRepository
    let employeeRepository: EmployeeRepository
    let customerRepository: CustomerRepository
    let productRepository: ProductRepository
    let cartRepository: CarRepository
    let salesRepository: SaleRepository
    let imageRepository: ImageRepository
    let powerSyncService: PowerSyncService
    init(sessionConfig: SessionConfig) {
        self.session = sessionConfig
        self.powerSyncService = PowerSyncService(sessionConfig: sessionConfig)
        //MARK: Helpers
        self.fileManager = LocalImageFileManagerImpl()
        //MARK: Local Managers
        self.localImageManager = LocalImageManagerImpl(fileManager: self.fileManager)
        self.sqlLiteSubsidiaryManager = SQLiteSubsidiaryManager(sessionConfig: sessionConfig, db: powerSyncService.db)
        self.sqlLiteEmployeeManager = SQLiteEmployeeManager(sessionConfig: sessionConfig, db: powerSyncService.db)
        self.sqlLiteCustomerManager = SQLiteCustomerManager(sessionConfig: sessionConfig, db: powerSyncService.db)
        self.sqlLiteProductManager = SQLiteProductManager(sessionConfig: sessionConfig, db: powerSyncService.db)
        self.sqlLiteCartManager = SQLiteCartManager(sessionConfig: sessionConfig, db: powerSyncService.db)
        self.sqlLiteSaleManager = SQLiteSaleManager(sessionConfig: sessionConfig, db: powerSyncService.db)
        //MARK: Remote Managers
        self.remoteImageManager = RemoteImageManagerImpl()
        self.remoteProductManager = RemoteProductManagerImpl(sessionConfig: sessionConfig)
        self.remoteSaleManager = RemoteSaleManagerImpl(sessionConfig: sessionConfig)
        self.remoteCompanyManager = RemoteCompanyManagerImpl(sessionConfig: sessionConfig)
        self.remoteSubsidiaryManager = RemoteSubsidiaryManagerImpl(sessionConfig: sessionConfig)
        self.remoteEmployeeManager = RemoteEmployeeManagerImpl(sessionConfig: sessionConfig)
        self.remoteCustomerManager = RemoteCustomerManagerImpl(sessionConfig: sessionConfig)
        //MARK: Repositorios
        self.companyRepository = CompanyRepositoryImpl(remoteManager: remoteCompanyManager)
        self.subsidiaryRepository = SubsidiaryRepositoryImpl(localManager: sqlLiteSubsidiaryManager, remoteManager: remoteSubsidiaryManager)
        self.employeeRepository = EmployeeRepositoryImpl(localManager: sqlLiteEmployeeManager, remoteManager: remoteEmployeeManager)
        self.customerRepository = CustomerRepositoryImpl(localManager: sqlLiteCustomerManager, remoteManager: remoteCustomerManager)
        self.productRepository = ProductRepositoryImpl(localManager: sqlLiteProductManager, remoteManager: remoteProductManager)
        self.cartRepository = CarRepositoryImpl(localManager: sqlLiteCartManager)
        self.salesRepository = SaleRepositoryImpl(localManager: sqlLiteSaleManager, remoteManager: remoteSaleManager, localCartManager: sqlLiteCartManager)
        self.imageRepository = ImageRepositoryImpl(localManager: localImageManager, remoteManager: remoteImageManager)
    }
}

extension SessionContainer {
    static var preview: SessionContainer {
        SessionContainer(
            sessionConfig: SessionConfig(
                companyCic: UUID().uuidString,
                subsidiaryCic: UUID().uuidString,
                employeeCic: UUID().uuidString
            )
        )
    }
}
