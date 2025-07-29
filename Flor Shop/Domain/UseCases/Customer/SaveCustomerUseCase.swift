import Foundation

protocol SaveCustomerUseCase {
    
    func execute(customer: Customer) async throws
}

final class SaveCustomerInteractor: SaveCustomerUseCase {
//    private let synchronizerDBUseCase: SynchronizerDBUseCase
    private let customerRepository: CustomerRepository
    private let imageRepository: ImageRepository
    
    init(
//        synchronizerDBUseCase: SynchronizerDBUseCase,
        customerRepository: CustomerRepository,
        imageRepository: ImageRepository
    ) {
//        self.synchronizerDBUseCase = synchronizerDBUseCase
        self.customerRepository = customerRepository
        self.imageRepository = imageRepository
    }
    
    func execute(customer: Customer) async throws {
        do {
            try await self.customerRepository.save(customer: customer)
//            try await self.synchronizerDBUseCase.sync()
        } catch {
//            try await self.synchronizerDBUseCase.sync()
            throw error
        }
    }
}
