import SwiftUI
import AppRouter

struct MenuFlow {
    @ViewBuilder
    static func getView(_ subFlow: MenuRoutes) -> some View {
        switch subFlow {
        case .customerView(let parameters):
            CustomersView(parameters: parameters)
        case .addCustomerView:
            AddCustomerView()
        case .paymentView:
            PaymentView()
        case .customerHistoryView:
            CustomerHistoryView()
        }
    }
}
