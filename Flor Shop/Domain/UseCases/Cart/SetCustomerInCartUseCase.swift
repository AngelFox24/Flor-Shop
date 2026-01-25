import Foundation

protocol SetCustomerInCartUseCase {
    func execute(customerCic: String) async
}

final class SetCustomerInCartInteractor: SetCustomerInCartUseCase {
    private let cartRepository: CarRepository
    
    init(cartRepository: CarRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(customerCic: String) async {
        do {
            return try await self.cartRepository.setCustomerInCart(customerCic: customerCic)
        } catch {
            print("[SetCustomerInCartInteractor] Error: \(error)")
        }
    }
}
