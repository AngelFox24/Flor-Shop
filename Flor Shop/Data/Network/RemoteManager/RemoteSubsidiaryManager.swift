import Foundation

protocol RemoteSubsidiaryManager {
    func save(subsidiary: Subsidiary) async throws
}

final class RemoteSubsidiaryManagerImpl: RemoteSubsidiaryManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(subsidiary: Subsidiary) async throws {
        let urlRoute = APIEndpoint.Subsidiary.base
        let subsidiaryDTO = subsidiary.toSubsidiaryDTO(companyId: self.sessionConfig.companyId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: subsidiaryDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
