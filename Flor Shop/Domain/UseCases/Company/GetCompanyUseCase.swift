//
//  GetCompanyUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol GetCompanyUseCase {
    func execute(subsidiary: Subsidiary) -> Company?
}

final class GetCompanyInteractor: GetCompanyUseCase {
    
    private let companyRepository: CompanyRepository
    
    init(companyRepository: CompanyRepository) {
        self.companyRepository = companyRepository
    }
   
    func execute(subsidiary: Subsidiary) -> Company? {
        do {
            return try self.companyRepository.getSessionCompany()
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
