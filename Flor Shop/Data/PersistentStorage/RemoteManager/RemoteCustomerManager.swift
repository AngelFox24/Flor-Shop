import Foundation
import FlorShopDTOs

protocol RemoteCustomerManager {
    func save(customer: Customer) async throws
    func payDebt(customerCic: String, amount: Int) async throws -> Int
}

final class RemoteCustomerManagerImpl: RemoteCustomerManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(customer: Customer) async throws {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.saveCustomer(
            customer: customer.toCustomerDTO(),
            token: ScopedTokenWithSubdomain(scopedToken: scopedToken.accessToken, subdomain: self.sessionConfig.subdomain)
        )
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func payDebt(customerCic: String, amount: Int) async throws -> Int {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.payCustomerDebt(
            params: PayCustomerDebtServerDTO(customerCic: customerCic, amount: amount),
            token: ScopedTokenWithSubdomain(scopedToken: scopedToken.accessToken, subdomain: self.sessionConfig.subdomain)
        )
        let response: PayCustomerDebtClientDTO = try await NetworkManager.shared.perform(request, decodeTo: PayCustomerDebtClientDTO.self)
        return response.change
    }
}
