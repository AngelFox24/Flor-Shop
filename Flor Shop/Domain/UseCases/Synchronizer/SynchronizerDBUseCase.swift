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
}

final class SynchronizerDBInteractor: SynchronizerDBUseCase {
    private let persistentContainer: NSPersistentContainer
    private let imageRepository: Syncronizable
    private let companyRepository: Syncronizable
    private let subsidiaryRepository: Syncronizable
    private let customerRepository: Syncronizable
    private let employeeRepository: Syncronizable
    private let productRepository: Syncronizable
    private let saleRepository: Syncronizable
    
    init(
        persistentContainer: NSPersistentContainer,
        imageRepository: Syncronizable,
        companyRepository: Syncronizable,
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
    
    func sync() async throws {
        let backgroundTaskContext = self.persistentContainer.newBackgroundContext()
        backgroundTaskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundTaskContext.undoManager = nil
        print("Imagenes sincronizando ...")
        try await self.imageRepository.sync(backgroundContext: backgroundTaskContext)
        print("Compania sincronizando ...")
        try await self.companyRepository.sync(backgroundContext: backgroundTaskContext)
        print("Subsidiaria sincronizando ...")
        try await self.subsidiaryRepository.sync(backgroundContext: backgroundTaskContext)
        print("Customers sincronizando ...")
        try await self.customerRepository.sync(backgroundContext: backgroundTaskContext)
        print("Employees sincronizando ...")
        try await self.employeeRepository.sync(backgroundContext: backgroundTaskContext)
        print("Productos sincronizando ...")
        try await self.productRepository.sync(backgroundContext: backgroundTaskContext)
        print("Sales sincronizando ...")
        try await self.saleRepository.sync(backgroundContext: backgroundTaskContext)
        // Guarda los cambios en el contexto de fondo
        if backgroundTaskContext.hasChanges {
            try backgroundTaskContext.save()
        }
    }
}
