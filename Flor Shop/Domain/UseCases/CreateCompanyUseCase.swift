//
//  CreateCompanyUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol CreateCompanyUseCase {
    func execute(company: Company) -> Bool
}

final class CreateCompanyInteractor: CreateCompanyUseCase {
    private let companyRepository: CompanyRepository
    
    init(companyRepository: CompanyRepository) {
        self.companyRepository = companyRepository
    }
    
    func execute(company: Company) -> Bool {
        return self.companyRepository.addCompany(company: company)
    }
}
