import Foundation
import FlorShopDTOs

protocol CustomerRepository {
    func save(customer: Customer) async throws
    func payClientTotalDebt(customer: Customer) async throws -> Bool
    func getCustomers(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer]
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail]
    func getCustomer(customer: Customer) throws -> Customer?
}

class CustomerRepositoryImpl: CustomerRepository {
    let localManager: LocalCustomerManager
    let remoteManager: RemoteCustomerManager
    let cloudBD = true
    init(
        localManager: LocalCustomerManager,
        remoteManager: RemoteCustomerManager
    ) {
        self.localManager = localManager
        self.remoteManager = remoteManager
    }
    func payClientTotalDebt(customer: Customer) async throws -> Bool {
        guard let customerCic = customer.customerCic else {
            throw LocalStorageError.invalidInput("El cliente no tiene CIC")
        }
        if cloudBD {
            let change = try await self.remoteManager.payDebt(customerCic: customerCic, amount: customer.totalDebt.cents)
            //TODO: Improve error throwing
            if change != 0 {
                throw LocalStorageError.invalidInput("Quedo vuelto para el cliente: \(Money(change).solesString)")
            } else {
                return true
            }
        } else {
            return false
        }
    }
    func save(customer: Customer) async throws {
        if cloudBD {
            try await self.remoteManager.save(customer: customer)
        }
    }
    func getCustomers(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer] {
        return self.localManager.getCustomers(seachText: seachText, order: order, filter: filter, page: page, pageSize: pageSize)
    }
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail] {
        return self.localManager.getSalesDetailHistory(customer: customer, page: page, pageSize: pageSize)
    }
    func getCustomer(customer: Customer) throws -> Customer? {
        return try self.localManager.getCustomer(customer: customer)
    }
}
