import Foundation

protocol SaveCustomerUseCase {
    func execute(customer: Customer) async throws
}

final class SaveCustomerInteractor: SaveCustomerUseCase {
    private let customerRepository: CustomerRepository
    private let imageRepository: ImageRepository
    
    init(
        customerRepository: CustomerRepository,
        imageRepository: ImageRepository
    ) {
        self.customerRepository = customerRepository
        self.imageRepository = imageRepository
    }
    
    func execute(customer: Customer) async throws {
        try await self.customerRepository.save(customer: customer)
    }
}
