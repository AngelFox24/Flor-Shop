//
//  SynchronizerDBUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

protocol SynchronizerDBUseCase {
    func sync() async throws
}

final class SynchronizerDBInteractor: SynchronizerDBUseCase {
    private let imageRepository: ImageRepository
    private let companyRepository: CompanyRepository
    private let subsidiaryRepository: SubsidiaryRepository
    private let customerRepository: CustomerRepository
    private let employeeRepository: EmployeeRepository
    private let productRepository: ProductRepository
    private let saleRepository: SaleRepository
    
    init(
        imageRepository: ImageRepository,
        companyRepository: CompanyRepository,
        subsidiaryRepository: SubsidiaryRepository,
        customerRepository: CustomerRepository,
        employeeRepository: EmployeeRepository,
        productRepository: ProductRepository,
        saleRepository: SaleRepository
    ) {
        self.imageRepository = imageRepository
        self.companyRepository = companyRepository
        self.subsidiaryRepository = subsidiaryRepository
        self.customerRepository = customerRepository
        self.employeeRepository = employeeRepository
        self.productRepository = productRepository
        self.saleRepository = saleRepository
    }
    
    func sync() async throws {
        try await self.imageRepository.sync()
        try await self.companyRepository.sync()
        try await self.subsidiaryRepository.sync()
        try await self.customerRepository.sync()
        try await self.employeeRepository.sync()
        try await self.productRepository.sync()
        try await self.saleRepository.sync()
    }
}
