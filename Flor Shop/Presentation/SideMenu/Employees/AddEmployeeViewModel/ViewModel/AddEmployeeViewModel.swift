import Foundation
import FlorShopDTOs

@Observable
final class AddEmployeeViewModel {
    var email: String = ""
    var role: UserSubsidiaryRole?
    private let getEmployeesUseCase: GetEmployeesUseCase
    init(getEmployeesUseCase: GetEmployeesUseCase) {
        self.getEmployeesUseCase = getEmployeesUseCase
    }
    func inviteEmployee() async throws {
        guard let role else { return }
        try await self.getEmployeesUseCase.inviteEmployee(email: email, role: role)
    }
}
