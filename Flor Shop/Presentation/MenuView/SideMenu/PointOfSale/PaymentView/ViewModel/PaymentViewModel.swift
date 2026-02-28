import Foundation
import FlorShopDTOs

enum PaymentTransaction: Equatable {
    static func == (lhs: PaymentTransaction, rhs: PaymentTransaction) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true

            case let (.send(lCar, lCustomer, lType),
                      .send(rCar, rCustomer, rType)):

                return lCar.id == rCar.id &&
                       lCustomer?.customerCic == rCustomer?.customerCic &&
                       lType == rType

            default:
                return false
            }
        }
    
    case none
    case send(car: Car, customer: Customer?, paymentType: PaymentType)
}

@Observable
final class PaymentViewModel: AlertPresenting {
    var alert: Bool = false
    var alertInfo: AlertInfo?
    var cartCoreData: Car?
    var customerInCar: Customer?
    var paymentType: PaymentType = .cash
    var isLoading: Bool = false
    var disabled: Bool {
        cartCoreData == nil
    }
    var paymentTransaction: PaymentTransaction = .none
    var paymentTypes: [PaymentType] {
        guard let customer = customerInCar else {
            return [.cash]
        }
        if customer.isCreditLimitActive || customer.isDateLimitActive {
            return PaymentType.allCases
        } else {
            return [.cash]
        }
    }
    var totalDisplay: String {
        guard let car = cartCoreData else {
            return "0.00"
        }
        switch paymentType {
        case .cash:
            return car.totalRounded.solesString
        case .loan:
            return car.total.solesString
        }
    }
    var registerTask: Task<Void, Never>?
    //Use Cases
    private let getCartUseCase: GetCartUseCase
    private let emptyCartUseCase: EmptyCartUseCase
    private let registerSaleUseCase: RegisterSaleUseCase
    private let getCustomersUseCase: GetCustomersUseCase
    private let setCustomerInCartUseCase: SetCustomerInCartUseCase
    
    init(
        registerSaleUseCase: RegisterSaleUseCase,
        getCartUseCase: GetCartUseCase,
        emptyCartUseCase: EmptyCartUseCase,
        getCustomersUseCase: GetCustomersUseCase,
        setCustomerInCartUseCase: SetCustomerInCartUseCase
    ) {
        self.registerSaleUseCase = registerSaleUseCase
        self.getCartUseCase = getCartUseCase
        self.emptyCartUseCase = emptyCartUseCase
        self.getCustomersUseCase = getCustomersUseCase
        self.setCustomerInCartUseCase = setCustomerInCartUseCase
    }
    
    @MainActor
    func fetchCart() async {
        self.cartCoreData = await self.getCartUseCase.execute()
        await fechtCustomer()
    }
    
    func fechtCustomer() async {
        let customerInCar: Customer?
        if let customerCic = cartCoreData?.customerCic {
            customerInCar = await self.getCustomersUseCase.getCustomer(customerCic: customerCic)
        } else {
            customerInCar = nil
        }
        await MainActor.run {
            self.customerInCar = customerInCar
        }
    }
    func emptyCart() async throws {
        try await self.emptyCartUseCase.execute()
        await fetchCart()
    }
    @MainActor
    private func clearView() {
        self.customerInCar = nil
        self.cartCoreData = nil
    }
    @MainActor
    func setSaleTransacction() {
        guard let cart = cartCoreData else { return }
        self.paymentTransaction = .send(car: cart, customer: self.customerInCar, paymentType: self.paymentType)
    }
    @MainActor
    func registerSale() async {
        self.isLoading = true
            guard let cart = cartCoreData else {
                await MainActor.run {
                    self.isLoading = false
                }
                return
            }
            do {
                try Task.checkCancellation()
                try await self.registerSaleUseCase.execute(cart: cart, paymentType: paymentType, customerCic: customerInCar?.customerCic)
                self.clearView()
                await MainActor.run {
                    self.isLoading = false
                }
            } catch is CancellationError {
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                let alertInfo = AlertInfo(tittle: "Error", message: error.localizedDescription, mainButton: AlertInfo.ButtonConfig(text: "Aceptar", action: { [weak self] in
                    self?.dismissAlert()
                    self?.isLoading = false
                }))
                await showAlert(alertInfo: alertInfo)
            }
    }
    func unlinkClient() {
        Task {
            guard let _ = customerInCar else { return }
            await self.setCustomerInCartUseCase.execute(customerCic: nil)
            await fetchCart()
        }
    }
}
