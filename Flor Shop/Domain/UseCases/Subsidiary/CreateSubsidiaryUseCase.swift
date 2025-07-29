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
        return try await self.subsidiaryRepository.save(subsidiary: subsidiary)
    }
}
