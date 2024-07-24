//
//  NavManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/10/23.
//

import Foundation
import SwiftUI

enum SessionRoutes {
    case loginView
    case registrationView
}

enum MenuRoutes {
    case customerView
    case customersForPaymentView
    case addCustomerView
    case paymentView
    case customerHistoryView
    
//    static var allValues: [NavPathsEnum] {
//        return [.loginView, .registrationView, .customerView, .customersForPaymentView, .addCustomerView, .paymentView, .customerHistoryView]
//    }
}

class NavManager: ObservableObject {
    @Published var navPaths = NavigationPath()
    
    func goToBack() {
        navPaths.removeLast()
    }
    func popToRoot() {
        navPaths = NavigationPath()
    }
    func goToLoginView() {
        navPaths.append(SessionRoutes.loginView)
    }
    func goToRegistrationView() {
        navPaths.append(SessionRoutes.registrationView)
    }
    func goToCustomerView() {
        navPaths.append(MenuRoutes.customerView)
    }
    func goToCustomerForPaymentView() {
        navPaths.append(MenuRoutes.customersForPaymentView)
    }
    func goToAddCustomerView() {
        navPaths.append(MenuRoutes.addCustomerView)
    }
    func goToPaymentView() {
        navPaths.append(MenuRoutes.paymentView)
    }
    func goToCustomerHistoryView() {
        navPaths.append(MenuRoutes.customerHistoryView)
    }
}
