import CoreData
import Foundation

@Observable
final class SessionContainer {
    //Main Context
    private let mainContext: NSManagedObjectContext
    //Services
    private let fileManager: LocalImageFileManager
    //Local Managers
    private let localImageManager: LocalImageManagerImpl
    private let localCompanyManager: LocalCompanyManagerImpl
    private let localSubsidiaryManager: LocalSubsidiaryManagerImpl
    private let localEmployeeManager: LocalEmployeeManagerImpl
    private let localCustomerManager: LocalCustomerManagerImpl
    private let localProductManager: LocalProductManagerImpl
    private let localCartManager: LocalCartManagerImpl
    private let localSaleManager: LocalSaleManagerImpl
    private let localProductSubsidiaryManager: LocalProductSubsidiaryManagerImpl
    private let localEmployeeSubsidiaryManager: LocalEmployeeSubsidiaryManagerImpl
    //Remote Managers
    private let remoteImageManager: RemoteImageManagerImpl
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
    let productSubsidiaryRepository: ProductSubsidiaryRepository
    let employeeSubsidiaryRepository: EmployeeSubsidiaryRepository
    let imageRepository: ImageRepository
    let syncRepository: SyncRepository
    init(sessionConfig: SessionConfig) {
        self.mainContext = FlorShopCoreDBProvider.shared.viewContext
        //MARK: Helpers
        self.fileManager = LocalImageFileManagerImpl()
        //MARK: Local Managers
        self.localImageManager = LocalImageManagerImpl(fileManager: self.fileManager, mainContext: self.mainContext, sessionConfig: sessionConfig)
        self.localCompanyManager = LocalCompanyManagerImpl(mainContext: mainContext, sessionConfig: sessionConfig)
        self.localSubsidiaryManager = LocalSubsidiaryManagerImpl(mainContext: mainContext, sessionConfig: sessionConfig)
        self.localEmployeeManager = LocalEmployeeManagerImpl(mainContext: mainContext, sessionConfig: sessionConfig)
        self.localCustomerManager = LocalCustomerManagerImpl(mainContext: mainContext, sessionConfig: sessionConfig)
        self.localProductManager = LocalProductManagerImpl(mainContext: mainContext, sessionConfig: sessionConfig)
        self.localCartManager = LocalCartManagerImpl(mainContext: mainContext, sessionConfig: sessionConfig)
        self.localSaleManager = LocalSaleManagerImpl(mainContext: mainContext, sessionConfig: sessionConfig)
        self.localProductSubsidiaryManager = LocalProductSubsidiaryManagerImpl(mainContext: mainContext, sessionConfig: sessionConfig)
        self.localEmployeeSubsidiaryManager = LocalEmployeeSubsidiaryManagerImpl(mainContext: mainContext, sessionConfig: sessionConfig)
        //MARK: Remote Managers
        self.remoteImageManager = RemoteImageManagerImpl()
        self.remoteProductManager = RemoteProductManagerImpl(sessionConfig: sessionConfig)
        self.remoteSaleManager = RemoteSaleManagerImpl(sessionConfig: sessionConfig)
        self.remoteCompanyManager = RemoteCompanyManagerImpl(sessionConfig: sessionConfig)
        self.remoteSubsidiaryManager = RemoteSubsidiaryManagerImpl(sessionConfig: sessionConfig)
        self.remoteEmployeeManager = RemoteEmployeeManagerImpl(sessionConfig: sessionConfig)
        self.remoteCustomerManager = RemoteCustomerManagerImpl(sessionConfig: sessionConfig)
        self.remoteSyncManager = RemoteSyncManagerImpl(sessionConfig: sessionConfig)
        //MARK: Repositorios
        self.companyRepository = CompanyRepositoryImpl(localManager: localCompanyManager, remoteManager: remoteCompanyManager)
        self.subsidiaryRepository = SubsidiaryRepositoryImpl(localManager: localSubsidiaryManager, remoteManager: remoteSubsidiaryManager)
        self.employeeRepository = EmployeeRepositoryImpl(localManager: localEmployeeManager, remoteManager: remoteEmployeeManager)
        self.customerRepository = CustomerRepositoryImpl(localManager: localCustomerManager, remoteManager: remoteCustomerManager)
        self.productRepository = ProductRepositoryImpl(localManager: localProductManager, remoteManager: remoteProductManager)
        self.cartRepository = CarRepositoryImpl(localManager: localCartManager)
        self.salesRepository = SaleRepositoryImpl(localManager: localSaleManager, remoteManager: remoteSaleManager)
        self.imageRepository = ImageRepositoryImpl(localManager: localImageManager, remoteManager: remoteImageManager)
        self.productSubsidiaryRepository = ProductSubsidiaryRepositoryImpl(localManager: localProductSubsidiaryManager)
        self.employeeSubsidiaryRepository = EmployeeSubsidiaryRepositoryImpl(localManager: localEmployeeSubsidiaryManager)
        self.syncRepository = SyncRepositoryImpl(remoteSyncManager: remoteSyncManager)
    }
}

extension SessionContainer {
    static var preview: SessionContainer {
        SessionContainer(
            sessionConfig: SessionConfig(
                subdomain: "previewSubdomain",
                companyCic: UUID().uuidString,
                subsidiaryCic: UUID().uuidString,
                employeeCic: UUID().uuidString
            )
        )
    }
}
