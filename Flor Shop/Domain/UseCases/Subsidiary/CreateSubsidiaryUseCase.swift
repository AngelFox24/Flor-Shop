//
//  CreateSubsidiaryUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol CreateSubsidiaryUseCase {
    func execute(subsidiary: Subsidiary) async throws
}
final class CreateSubsidiaryInteractor: CreateSubsidiaryUseCase {
    
    private let subsidiaryRepository: SubsidiaryRepository
    
    init(subsidiaryRepository: SubsidiaryRepository) {
        self.subsidiaryRepository = subsidiaryRepository
    }
     
    func execute(subsidiary: Subsidiary) async throws {
        return try await self.subsidiaryRepository.addSubsidiary(subsidiary: subsidiary)
    }
}
