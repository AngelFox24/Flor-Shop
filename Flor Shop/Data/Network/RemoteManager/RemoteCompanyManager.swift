import Foundation

protocol RemoteCompanyManager {
    func save(company: Company) async throws
    func getTokens(localTokens: VerifySyncParameters) async throws -> VerifySyncParameters
}

final class RemoteCompanyManagerImpl: RemoteCompanyManager {
    func save(company: Company) async throws {
        let urlRoute = APIEndpoint.Company.base
        let companyDTO = company.toCompanyDTO()
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: companyDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func getTokens(localTokens: VerifySyncParameters) async throws -> VerifySyncParameters {
        let urlRoute = APIEndpoint.Sync.base
        let requestParameters = localTokens
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: requestParameters)
        let data: VerifySyncParameters = try await NetworkManager.shared.perform(request, decodeTo: VerifySyncParameters.self)
        return data
    }
}
