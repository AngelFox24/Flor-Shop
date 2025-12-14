import Foundation

protocol PayClientDebtUseCase {
    func total(customer: Customer) async throws -> Bool
}

final class PayClientDebtInteractor: PayClientDebtUseCase {
    private let customerRepository: CustomerRepository
    
    init(
        customerRepository: CustomerRepository
    ) {
        self.customerRepository = customerRepository
    }
    
    func total(customer: Customer) async throws -> Bool {
        try await customerRepository.payClientTotalDebt(customer: customer)
    }
}

