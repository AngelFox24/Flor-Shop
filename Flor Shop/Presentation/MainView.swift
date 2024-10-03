//
//  MainView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/07/2024.
//

import SwiftUI

struct MainView: View {
    let dependencies: BusinessDependencies
    @Binding var loading: Bool
    @State var showMenu: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            MenuView(loading: $loading, showMenu: $showMenu)
                .environmentObject(dependencies.productsViewModel)
                .environmentObject(dependencies.cartViewModel)
                .environmentObject(dependencies.salesViewModel)
                .environmentObject(dependencies.customerViewModel)
                .environmentObject(dependencies.addCustomerViewModel)
                .environmentObject(dependencies.employeeViewModel)
                .environmentObject(dependencies.agregarViewModel)
                .environmentObject(dependencies.customerHistoryViewModel)
                .environmentObject(dependencies.addCustomerViewModel)
        }
        .navigationDestination(for: MenuRoutes.self) { routes in
            switch routes {
            case .customerView:
                CustomersView(backButton: true, showMenu: $showMenu)
                    .environmentObject(dependencies.customerViewModel)
                    .environmentObject(dependencies.cartViewModel)
                    .environmentObject(dependencies.addCustomerViewModel)
                    .environmentObject(dependencies.customerHistoryViewModel)
            case .customersForPaymentView:
                CustomersView(backButton: true, showMenu: $showMenu)
                    .environmentObject(dependencies.customerViewModel)
                    .environmentObject(dependencies.cartViewModel)
                    .environmentObject(dependencies.addCustomerViewModel)
                    .environmentObject(dependencies.customerHistoryViewModel)
            case .addCustomerView:
                AddCustomerView(loading: $loading)
                    .environmentObject(dependencies.addCustomerViewModel)
                    .environmentObject(dependencies.customerHistoryViewModel)
            case .paymentView:
                PaymentView(loading: $loading)
                    .environmentObject(dependencies.cartViewModel)
                    .environmentObject(dependencies.salesViewModel)

            case .customerHistoryView:
                CustomerHistoryView(loading: $loading)
                    .environmentObject(dependencies.customerHistoryViewModel)
                    .environmentObject(dependencies.addCustomerViewModel)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let normalDependencies = NormalDependencies()
        let sesC = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dep = BusinessDependencies(sessionConfig: sesC)
        @State var loading = false
        MainView(dependencies: dep, loading: $loading)
            .environmentObject(normalDependencies.navManager)
            .environmentObject(normalDependencies.versionCheck)
            .environmentObject(normalDependencies.logInViewModel)
            .environmentObject(normalDependencies.errorState)
    }
}
