import Foundation
import FlorShopDTOs

protocol RemoteEmployeeManager {
    func save(employee: Employee) async throws
    func invite(email: String, role: UserSubsidiaryRole) async throws
}

final class RemoteEmployeeManagerImpl: RemoteEmployeeManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(employee: Employee) async throws {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.saveEmployee(
            employee: employee.toEmployeeDTO(),
            token: scopedToken.accessToken
        )
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func invite(email: String, role: UserSubsidiaryRole) async throws {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopAuthApiRequest.registerInvitation(request: InvitationRequest(email: email, role: role), scopedToken: scopedToken.accessToken)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
