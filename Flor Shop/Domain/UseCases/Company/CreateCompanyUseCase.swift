//
//  CreateCompanyUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol CreateCompanyUseCase {
    func execute(company: Company) async throws
}

final class CreateCompanyInteractor: CreateCompanyUseCase {
    private let companyRepository: CompanyRepository
    
    init(companyRepository: CompanyRepository) {
        self.companyRepository = companyRepository
    }
    
    func execute(company: Company) async throws {
        try await self.companyRepository.save(company: company)
    }
}
