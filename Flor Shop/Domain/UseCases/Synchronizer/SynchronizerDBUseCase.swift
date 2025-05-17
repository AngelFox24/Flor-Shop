//
//  SynchronizerDBUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation
import CoreData

protocol SynchronizerDBUseCase {
    func sync() async throws
    func sync(verifySyncParameters: VerifySyncParameters) async throws
    var lastSyncDate: Date? { get async }  // Solo lectura
    var syncTokens: VerifySyncParameters { get set }
}

actor SyncController {
    private(set) var lastSyncDate: Date?
    func performSync(_ task: () async throws -> Void) async rethrows {
        try await task()
        lastSyncDate = Date()
    }
    func getLastSyncDate() -> Date? {
        return lastSyncDate
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
    
    var syncTokens: VerifySyncParameters = VerifySyncParameters(
        imageLastUpdate: UUID(),
        companyLastUpdate: UUID(),
        subsidiaryLastUpdate: UUID(),
        customerLastUpdate: UUID(),
        productLastUpdate: UUID(),
        employeeLastUpdate: UUID(),
        saleLastUpdate: UUID()
    )
    
    private let syncController = SyncController()
    var lastSyncDate: Date? {
        get async {
            await syncController.getLastSyncDate()  // Acceso seguro a la propiedad
        }
    }
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
    
    func sync(verifySyncParameters: VerifySyncParameters) async throws {
        try await syncController.performSync {
            let backgroundTaskContext = self.persistentContainer.newBackgroundContext()
            backgroundTaskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            backgroundTaskContext.undoManager = nil
            for _ in 0..<3 {
                do {
                    let newSyncTokens = verifySyncParameters
                    if newSyncTokens.companyLastUpdate != self.syncTokens.companyLastUpdate {
                        print("Compania sincronizando ...")
                        self.syncTokens = try await self.companyRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.imageLastUpdate != self.syncTokens.imageLastUpdate {
                        print("Imagenes sincronizando ...")
                        self.syncTokens = try await self.imageRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.subsidiaryLastUpdate != self.syncTokens.subsidiaryLastUpdate {
                        print("Subsidiaria sincronizando ...")
                        self.syncTokens = try await self.subsidiaryRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.customerLastUpdate != self.syncTokens.customerLastUpdate {
                        print("Customers sincronizando ...")
                        self.syncTokens = try await self.customerRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.employeeLastUpdate != self.syncTokens.employeeLastUpdate {
                        print("Employees sincronizando ...")
                        self.syncTokens = try await self.employeeRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.productLastUpdate != self.syncTokens.productLastUpdate {
                        print("Productos sincronizando ...")
                        self.syncTokens = try await self.productRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.saleLastUpdate != self.syncTokens.saleLastUpdate {
                        print("Sales sincronizando ...")
                        self.syncTokens = try await self.saleRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    break
                } catch {
                    if !error.localizedDescription.contains("Parents are not up to date") {
                        throw error
                    }
                }
            }
        }
    }
    
    func sync() async throws {
        try await syncController.performSync {
            let backgroundTaskContext = self.persistentContainer.newBackgroundContext()
            backgroundTaskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            backgroundTaskContext.undoManager = nil
            for _ in 0..<3 {
                do {
                    let newSyncTokens = try await self.companyRepository.getSyncTokens(localTokens: self.syncTokens)
                    if newSyncTokens.companyLastUpdate != self.syncTokens.companyLastUpdate {
                        print("Compania sincronizando ...")
                        self.syncTokens = try await self.companyRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.imageLastUpdate != self.syncTokens.imageLastUpdate {
                        print("Imagenes sincronizando ...")
                        self.syncTokens = try await self.imageRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.subsidiaryLastUpdate != self.syncTokens.subsidiaryLastUpdate {
                        print("Subsidiaria sincronizando ...")
                        self.syncTokens = try await self.subsidiaryRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.customerLastUpdate != self.syncTokens.customerLastUpdate {
                        print("Customers sincronizando ...")
                        self.syncTokens = try await self.customerRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.employeeLastUpdate != self.syncTokens.employeeLastUpdate {
                        print("Employees sincronizando ...")
                        self.syncTokens = try await self.employeeRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.productLastUpdate != self.syncTokens.productLastUpdate {
                        print("Productos sincronizando ...")
                        self.syncTokens = try await self.productRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    if newSyncTokens.saleLastUpdate != self.syncTokens.saleLastUpdate {
                        print("Sales sincronizando ...")
                        self.syncTokens = try await self.saleRepository.sync(backgroundContext: backgroundTaskContext, syncTokens: syncTokens)
                    }
                    break
                } catch {
                    if !error.localizedDescription.contains("Parents are not up to date") {
                        throw error
                    }
                }
            }
        }
    }
}
