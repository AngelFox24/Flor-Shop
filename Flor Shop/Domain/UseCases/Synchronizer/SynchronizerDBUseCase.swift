import Foundation
import CoreData
import FlorShopDTOs

protocol SynchronizerDBUseCase {
    func sync(globalSyncToken: Int64, branchSyncToken: Int64) async throws -> (globalSyncToken: Int64, branchSyncToken: Int64)
    func getLastToken() -> LastTokenByEntities
}

final class SynchronizerDBInteractorMock: SynchronizerDBUseCase {
    func sync(globalSyncToken: Int64, branchSyncToken: Int64) async throws -> (globalSyncToken: Int64, branchSyncToken: Int64) {
        return (0, 0)
    }
    func getLastToken() -> LastTokenByEntities {
        return LastTokenByEntities(
            company: 0,
            subsidiary: 0,
            customer: 0,
            employee: 0,
            product: 0,
            sale: 0,
            productSubsidiary: 0,
            employeeSubsidiary: 0
        )
    }
}

final class SynchronizerDBInteractor: SynchronizerDBUseCase {
    private let persistentContainer: NSPersistentContainer
    private let companyRepository: Syncronizable & CompanyRepository
    private let subsidiaryRepository: Syncronizable
    private let customerRepository: Syncronizable
    private let employeeRepository: Syncronizable
    private let productRepository: Syncronizable
    private let saleRepository: Syncronizable
    private let productSubsidiaryRepository: Syncronizable
    private let employeeSubsidiaryRepository: Syncronizable
    private let syncRepository: SyncRepository
    
    init(
        persistentContainer: NSPersistentContainer,
        companyRepository: Syncronizable & CompanyRepository,
        subsidiaryRepository: Syncronizable,
        customerRepository: Syncronizable,
        employeeRepository: Syncronizable,
        productRepository: Syncronizable,
        saleRepository: Syncronizable,
        productSubsidiaryRepository: Syncronizable,
        employeeSubsidiaryRepository: Syncronizable,
        syncRepository: SyncRepository
    ) {
        self.persistentContainer = persistentContainer
        self.companyRepository = companyRepository
        self.subsidiaryRepository = subsidiaryRepository
        self.customerRepository = customerRepository
        self.employeeRepository = employeeRepository
        self.productRepository = productRepository
        self.saleRepository = saleRepository
        self.productSubsidiaryRepository = productSubsidiaryRepository
        self.employeeSubsidiaryRepository = employeeSubsidiaryRepository
        self.syncRepository = syncRepository
    }
    
    func sync(globalSyncToken: Int64, branchSyncToken: Int64) async throws -> (globalSyncToken: Int64, branchSyncToken: Int64) {// 0.231891 segundos aprox ??????
        //            let clock = ContinuousClock()
        //            let start = clock.now
        print("[SynchronizerDBInteractor] Syncrhonizando...")
        let backgroundTaskContext = self.persistentContainer.newBackgroundContext()
        backgroundTaskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundTaskContext.undoManager = nil
        do {
            let syncClientParameters: SyncResponse = try await self.syncRepository.sync(globalSyncToken: globalSyncToken, branchSyncToken: branchSyncToken)
            try await self.companyRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.subsidiaryRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.customerRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.employeeRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.productRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.saleRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.productSubsidiaryRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.employeeSubsidiaryRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            return (syncClientParameters.lastGlobalToken, syncClientParameters.lastBranchToken)
        } catch {
            if !error.localizedDescription.contains("Parents are not up to date") {
                throw error
            } else {
                throw error
            }
        }
        //            let duration = start.duration(to: clock.now)
        //            let seconds = duration.components.seconds
        //            let attoseconds = duration.components.attoseconds

                    // Convertir la fracción a segundos como Double
        //            let fractionalSeconds = Double(seconds) + Double(attoseconds) / 1_000_000_000_000_000_000

        //            print(String(format: "[SynchronizerDBInteractor] Tiempo de ejecución: %.6f segundos", fractionalSeconds))
    }
    
    func getLastToken() -> LastTokenByEntities {
        let companyLastToken = self.companyRepository.getLastToken()
        let subsidiaryLastToken = self.subsidiaryRepository.getLastToken()
        let customerLastToken = self.customerRepository.getLastToken()
        let employeeLastToken = self.employeeRepository.getLastToken()
        let productLastToken = self.productRepository.getLastToken()
        let saleLastToken = self.saleRepository.getLastToken()
        let productSubsidiaryLastToken = self.productSubsidiaryRepository.getLastToken()
        let employeeSubsidiaryLastToken = self.employeeSubsidiaryRepository.getLastToken()
        return LastTokenByEntities(
            company: companyLastToken,
            subsidiary: subsidiaryLastToken,
            customer: customerLastToken,
            employee: employeeLastToken,
            product: productLastToken,
            sale: saleLastToken,
            productSubsidiary: productSubsidiaryLastToken,
            employeeSubsidiary: employeeSubsidiaryLastToken
        )
    }
}
