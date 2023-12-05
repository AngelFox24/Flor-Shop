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
    
    private let subsidiaryRepository: SubsidiaryRepository
    
    init(subsidiaryRepository: SubsidiaryRepository) {
        self.subsidiaryRepository = subsidiaryRepository
    }
   
    func execute(subsidiary: Subsidiary) -> Company? {
        return self.subsidiaryRepository.getCompany(subsidiary: subsidiary)
    }
}
