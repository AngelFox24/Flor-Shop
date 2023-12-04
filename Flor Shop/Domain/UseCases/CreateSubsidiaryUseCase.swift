//
//  CreateSubsidiaryUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol CreateSubsidiaryUseCase {
    func execute(subsidiary: Subsidiary) -> Bool
}
final class CreateSubsidiaryInteractor: CreateSubsidiaryUseCase {
    
    private let subsidiaryRepository: SubsidiaryRepository
    
    init(subsidiaryRepository: SubsidiaryRepository) {
        self.subsidiaryRepository = subsidiaryRepository
    }
     
    func execute(subsidiary: Subsidiary) -> Bool {
        //return self.subsidiaryRepository.addSubsidiary(subsidiary: subsidiary)
        return true
    }
}
