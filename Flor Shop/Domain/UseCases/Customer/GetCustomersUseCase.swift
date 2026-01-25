import Foundation

protocol GetCustomersUseCase {
    func execute(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int) async -> [Customer]
    func getCustomer(customerCic: String) async -> Customer?
}

final class GetCustomersInteractor: GetCustomersUseCase {
    private let customerRepository: CustomerRepository
    
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    
    func execute(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int) async -> [Customer] {
        do {
            return try await self.customerRepository.getCustomers(seachText: seachText, order: order, filter: filter, page: page, pageSize: 20)
        } catch {
            print("[GetCustomersInteractor] Error: \(error)")
            return []
        }
    }
    
    func getCustomer(customerCic: String) async -> Customer? {
        do {
            return try await self.customerRepository.getCustomer(customerCic: customerCic)
        } catch {
            print("[GetCustomersInteractor] Error: \(error)")
            return nil
        }
    }
}
