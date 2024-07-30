//
//  CreateCompanyUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol CreateCompanyUseCase {
    func execute(company: Company) throws
}

final class CreateCompanyInteractor: CreateCompanyUseCase {
    private let companyRepository: CompanyRepository
    
    init(companyRepository: CompanyRepository) {
        self.companyRepository = companyRepository
    }
    
    func execute(company: Company) throws {
        try self.companyRepository.save(company: company)
    }
}
