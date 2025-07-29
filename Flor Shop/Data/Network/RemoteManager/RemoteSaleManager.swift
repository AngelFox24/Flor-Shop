import Foundation

protocol RemoteSaleManager {
    func save(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws
}

final class RemoteSaleManagerImpl: RemoteSaleManager {
    let sessionConfig: SessionConfig
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    func save(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws {
        let urlRoute = APIEndpoint.Sale.base
        let cartDTO = cart.toCartDTO(subsidiaryId: self.sessionConfig.subsidiaryId)
        let saleTransactionDTO = RegisterSaleParameters(
            subsidiaryId: self.sessionConfig.subsidiaryId,
            employeeId: self.sessionConfig.employeeId,
            customerId: customerId,
            paymentType: paymentType.description,
            cart: cartDTO
        )
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: saleTransactionDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
