import Foundation
import FlorShopDTOs
import FlorShopNetworking

protocol RemoteSaleManager {
    func save(cart: Car, paymentType: PaymentType, customerCic: String?) async throws
}

final class RemoteSaleManagerImpl: RemoteSaleManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(cart: Car, paymentType: PaymentType, customerCic: String?) async throws {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw LocalStorageError.invalidInput("[RemoteProductManagerImpl] Scoped token is invalid")
        }
        let request = FlorShopCoreApiRequest.registerSale(
            sale: RegisterSaleParameters(
                customerCic: customerCic,
                paymentType: paymentType,
                cart: cart.toCartDTO()),
            token: scopedToken.accessToken)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
