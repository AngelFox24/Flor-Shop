import Foundation
import FlorShopDTOs
import FlorShopNetworking

protocol RemoteProductManager {
    func save(product: Product) async throws
}

final class RemoteProductManagerImpl: RemoteProductManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(product: Product) async throws {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw LocalStorageError.invalidInput("[RemoteProductManagerImpl] Scoped token is invalid")
        }
        let request = FlorShopCoreApiRequest.saveProduct(
            product: product.toProductDTO(),
            token: scopedToken.accessToken
        )
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
