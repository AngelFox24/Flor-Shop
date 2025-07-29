import Foundation

protocol RemoteCustomerManager {
    func save(customer: Customer) async throws
    func payDebt(customerId: UUID, amount: Int) async throws -> Int
}

final class RemoteCustomerManagerImpl: RemoteCustomerManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(customer: Customer) async throws {
        let urlRoute = APIEndpoint.Customer.base
        let customerDTO = customer.toCustomerDTO(companyId: self.sessionConfig.companyId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: customerDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func payDebt(customerId: UUID, amount: Int) async throws -> Int {
        let urlRoute = APIEndpoint.Customer.payDebt
        let payCustomerDebt = PayCustomerDebtParameters(customerId: customerId, amount: amount)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: payCustomerDebt)
        let response: PayCustomerDebtResponse = try await NetworkManager.shared.perform(request, decodeTo: PayCustomerDebtResponse.self)
        return response.change
    }
}
