//
//  MainView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/07/2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var logInViewModel: LogInViewModel
    @State private var showMenu: Bool = false
    @Binding private var isKeyboardVisible: Bool
    let dependencies: BusinessDependencies
    var body: some View {
        ZStack(content: {
            MenuView(showMenu: $showMenu, isKeyboardVisible: $isKeyboardVisible)
                .environmentObject(dependencies.productsViewModel)
                .environmentObject(dependencies.cartViewModel)
                .environmentObject(dependencies.salesViewModel)
                .environmentObject(dependencies.customerViewModel)
                .environmentObject(dependencies.addCustomerViewModel)
                .environmentObject(dependencies.employeeViewModel)
        })
        .navigationDestination(for: MenuRoutes.self) { routes in
            switch routes {
            case .customerView:
                CustomersView(showMenu: $showMenu, backButton: true)
                    .environmentObject(dependencies.customerViewModel)
                    .environmentObject(dependencies.cartViewModel)
                    .environmentObject(dependencies.addCustomerViewModel)
                    .environmentObject(dependencies.customerHistoryViewModel)
            case .customersForPaymentView:
                CustomersView(showMenu: .constant(false), backButton: true)
                    .environmentObject(dependencies.customerViewModel)
                    .environmentObject(dependencies.cartViewModel)
                    .environmentObject(dependencies.addCustomerViewModel)
                    .environmentObject(dependencies.customerHistoryViewModel)
            case .addCustomerView:
                AddCustomerView()
                    .environmentObject(dependencies.addCustomerViewModel)
            case .paymentView:
                PaymentView()
                    .environmentObject(dependencies.cartViewModel)
            case .customerHistoryView:
                CustomerHistoryView()
                    .environmentObject(dependencies.customerHistoryViewModel)
            }
        }
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        let depN = NormalDependencies()
//        let sesC = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
//        let dep = BusinessDependencies(sessionConfig: sesC)
//        MainView(isKeyboardVisible: .constant(true), dependencies: dep)
//            .environmentObject(depN.logInViewModel)
//    }
//}
