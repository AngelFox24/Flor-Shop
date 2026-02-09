import Foundation

protocol GetCustomerSalesUseCase {
    func execute(customerCic: String, page: Int) async -> [SaleDetail]
}

final class GetCustomerSalesInteractor: GetCustomerSalesUseCase {
    private let customerRepository: CustomerRepository
    
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    
    func execute(customerCic: String, page: Int) async -> [SaleDetail] {
        do {
            return try await self.customerRepository.getSalesDetailHistory(customerCic: customerCic, page: page, pageSize: 20)
        } catch {
            print("[GetCustomerSalesInteractor] Error: \(error)")
            return []
        }
    }
}
