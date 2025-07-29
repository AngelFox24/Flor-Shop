import Foundation

protocol RemoteEmployeeManager {
    func save(employee: Employee) async throws
}

final class RemoteEmployeeManagerImpl: RemoteEmployeeManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(employee: Employee) async throws {
        let urlRoute = APIEndpoint.Employee.base
        let employeeDTO = employee.toEmployeeDTO(subsidiaryId: self.sessionConfig.subsidiaryId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: employeeDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
