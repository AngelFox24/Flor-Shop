//
//  SynchronizerDBUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation
import CoreData

protocol SynchronizerDBUseCase {
    func sync(newToken: Int64) async throws
    func getLastToken(context: NSManagedObjectContext) -> Int64
}

final class SynchronizerDBInteractorMock: SynchronizerDBUseCase {
    func sync(newToken: Int64) async throws {
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        return 0
    }
}

final class SynchronizerDBInteractor: SynchronizerDBUseCase {
    private let persistentContainer: NSPersistentContainer
    private let imageRepository: Syncronizable
    private let companyRepository: Syncronizable & CompanyRepository
    private let subsidiaryRepository: Syncronizable
    private let customerRepository: Syncronizable
    private let employeeRepository: Syncronizable
    private let productRepository: Syncronizable
    private let saleRepository: Syncronizable
    
    init(
        persistentContainer: NSPersistentContainer,
        imageRepository: Syncronizable,
        companyRepository: Syncronizable & CompanyRepository,
        subsidiaryRepository: Syncronizable,
        customerRepository: Syncronizable,
        employeeRepository: Syncronizable,
        productRepository: Syncronizable,
        saleRepository: Syncronizable
    ) {
        self.persistentContainer = persistentContainer
        self.imageRepository = imageRepository
        self.companyRepository = companyRepository
        self.subsidiaryRepository = subsidiaryRepository
        self.customerRepository = customerRepository
        self.employeeRepository = employeeRepository
        self.productRepository = productRepository
        self.saleRepository = saleRepository
    }
    
    func sync(newToken: Int64) async throws {// 0.231891 segundos aprox ??????
        //            let clock = ContinuousClock()
        //            let start = clock.now
        let backgroundTaskContext = self.persistentContainer.newBackgroundContext()
        backgroundTaskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundTaskContext.undoManager = nil
        do {
            //TODO: Get from repository
            let syncClientParameters: SyncClientParameters = SyncClientParameters(
                images: [],
                company: nil,
                subsidiaries: [],
                employees: [],
                customers: [],
                products: [],
                sales: [],
                salesDetail: [],
                isUpToDate: false
            )
            try await self.imageRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.companyRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.subsidiaryRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.customerRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.employeeRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.productRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
            try await self.saleRepository.sync(backgroundContext: backgroundTaskContext, syncDTOs: syncClientParameters)
        } catch {
            if !error.localizedDescription.contains("Parents are not up to date") {
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
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        let imageUrlLastToken = self.imageRepository.getLastToken(context: context)
        let companyLastToken = self.companyRepository.getLastToken(context: context)
        let subsidiaryLastToken = self.subsidiaryRepository.getLastToken(context: context)
        let customerLastToken = self.customerRepository.getLastToken(context: context)
        let employeeLastToken = self.employeeRepository.getLastToken(context: context)
        let productLastToken = self.productRepository.getLastToken(context: context)
        let saleLastToken = self.saleRepository.getLastToken(context: context)
        return max(
            companyLastToken,
            subsidiaryLastToken,
            imageUrlLastToken,
            customerLastToken,
            employeeLastToken,
            productLastToken,
            saleLastToken
        )
    }
    
//    func sync(verifySyncParameters: VerifySyncParameters) async throws {// 0.231891 segundos aprox
//        try await syncController.performSync {
//            print("[SynchronizerDBInteractor] Iniciando sincronizacion ...")
////            let clock = ContinuousClock()
////            let start = clock.now
//            let backgroundTaskContext = self.persistentContainer.newBackgroundContext()
//            backgroundTaskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//            backgroundTaskContext.undoManager = nil
//            do {
//                let newSyncTokens = verifySyncParameters
//                if newSyncTokens.companyLastUpdate != self.syncTokens.companyLastUpdate {
//                    print("Compania sincronizando ...")
//                    self.syncTokens = try await self.companyRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
//                }
//                if newSyncTokens.imageLastUpdate != self.syncTokens.imageLastUpdate {
//                    print("Imagenes sincronizando ...")
//                    self.syncTokens = try await self.imageRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
//                }
//                if newSyncTokens.subsidiaryLastUpdate != self.syncTokens.subsidiaryLastUpdate {
//                    print("Subsidiaria sincronizando ...")
//                    self.syncTokens = try await self.subsidiaryRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
//                }
//                if newSyncTokens.customerLastUpdate != self.syncTokens.customerLastUpdate {
//                    print("Customers sincronizando ...")
//                    self.syncTokens = try await self.customerRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
//                }
//                if newSyncTokens.employeeLastUpdate != self.syncTokens.employeeLastUpdate {
//                    print("Employees sincronizando ...")
//                    self.syncTokens = try await self.employeeRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
//                }
//                if newSyncTokens.productLastUpdate != self.syncTokens.productLastUpdate {
//                    print("Productos sincronizando ...")
//                    self.syncTokens = try await self.productRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
//                }
//                if newSyncTokens.saleLastUpdate != self.syncTokens.saleLastUpdate {
//                    print("Sales sincronizando ...")
//                    self.syncTokens = try await self.saleRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
//                }
//            } catch {
//                if !error.localizedDescription.contains("Parents are not up to date") {
//                    throw error
//                }
//            }
////            let duration = start.duration(to: clock.now)
////            let seconds = duration.components.seconds
////            let attoseconds = duration.components.attoseconds
//
//            // Convertir la fracción a segundos como Double
////            let fractionalSeconds = Double(seconds) + Double(attoseconds) / 1_000_000_000_000_000_000
//
////            print(String(format: "[SynchronizerDBInteractor] Tiempo de ejecución: %.6f segundos", fractionalSeconds))
//        }
//    }
}
