//
//  MainView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/07/2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var logInViewModel: LogInViewModel
    let dependencies: BusinessDependencies
    var body: some View {
        ZStack(content: {
            MenuView()
                .environmentObject(dependencies.productsViewModel)
                .environmentObject(dependencies.cartViewModel)
                .environmentObject(dependencies.salesViewModel)
                .environmentObject(dependencies.customerViewModel)
                .environmentObject(dependencies.addCustomerViewModel)
                .environmentObject(dependencies.employeeViewModel)
                .environmentObject(dependencies.agregarViewModel)
        })
        .navigationDestination(for: MenuRoutes.self) { routes in
            switch routes {
            case .customerView:
                CustomersView(backButton: true)
                    .environmentObject(dependencies.customerViewModel)
                    .environmentObject(dependencies.cartViewModel)
                    .environmentObject(dependencies.addCustomerViewModel)
                    .environmentObject(dependencies.customerHistoryViewModel)
            case .customersForPaymentView:
                CustomersView(backButton: true)
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let normalDependencies = NormalDependencies()
        let sesC = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dep = BusinessDependencies(sessionConfig: sesC)
        MainView(dependencies: dep)
            .environmentObject(normalDependencies.navManager)
            .environmentObject(normalDependencies.versionCheck)
            .environmentObject(normalDependencies.logInViewModel)
            .environmentObject(normalDependencies.viewStates)
            .environmentObject(normalDependencies.errorState)
    }
}
