import Foundation
import FlorShopDTOs

@Observable
final class PaymentCustomerViewModel {
    var customer: Customer?
    var paymentType: PaymentType = .cash
    let paymentTypes: [PaymentType] = [.cash]
    private let getCustomersUseCase: GetCustomersUseCase
    private let payClientDebtUseCase: PayClientDebtUseCase
    
    init(
        getCustomersUseCase: GetCustomersUseCase,
        payClientDebtUseCase: PayClientDebtUseCase
    ) {
        self.getCustomersUseCase = getCustomersUseCase
        self.payClientDebtUseCase = payClientDebtUseCase
    }
    func updateUI(customerCic: String) async {
        let customer = await self.getCustomersUseCase.getCustomer(customerCic: customerCic)
        await MainActor.run {
            self.customer = customer
        }
    }
    func payCustomerTotalDebd() async throws {
        guard let customer else {
            return
        }
        let _ = try await self.payClientDebtUseCase.total(customer: customer)
    }
}
