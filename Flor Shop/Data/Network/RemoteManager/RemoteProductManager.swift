import Foundation

protocol RemoteProductManager {
    func save(product: Product) async throws
}

final class RemoteProductManagerImpl: RemoteProductManager {
    let sessionConfig: SessionConfig
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    func save(product: Product) async throws {
        let urlRoute = APIEndpoint.Product.base
        let productDTO = product.toProductDTO(subsidiaryId: self.sessionConfig.subsidiaryId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: productDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
