//
//  SetDefaultCompanyUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol SetDefaultCompanyUseCase {
    func execute(company: Company)
    func releaseResources()
}

final class SetDefaultCompanyInteractor: SetDefaultCompanyUseCase {
    
    private let companyRepository: CompanyRepository
    private let subsidiaryRepository: SubsidiaryRepository
    private let customerRepository: CustomerRepository
    
    init(companyRepository: CompanyRepository, subsidiaryRepository: SubsidiaryRepository, customerRepository: CustomerRepository) {
        self.companyRepository = companyRepository
        self.subsidiaryRepository = subsidiaryRepository
        self.customerRepository = customerRepository
    }
   
    func execute(company: Company) {
        self.companyRepository.setDefaultCompany(company: company)
        self.subsidiaryRepository.setDefaultCompany(company: company)
        self.customerRepository.setDefaultCompany(company: company)
    }
    
    func releaseResources() {
        self.companyRepository.releaseResourses()
        self.subsidiaryRepository.releaseResourses()
        self.customerRepository.releaseResourses()
    }
}
