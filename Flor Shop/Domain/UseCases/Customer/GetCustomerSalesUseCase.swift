import Foundation

protocol GetCustomerSalesUseCase {
    func execute(customer: Customer, page: Int) async -> [SaleDetail]
}

final class GetCustomerSalesInteractor: GetCustomerSalesUseCase {
    private let customerRepository: CustomerRepository
    
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    
    func execute(customer: Customer, page: Int) async -> [SaleDetail] {
        do {
            return try await self.customerRepository.getSalesDetailHistory(customer: customer, page: page, pageSize: 20)
        } catch {
            print("[GetCustomerSalesInteractor] Error: \(error)")
            return []
        }
    }
}
