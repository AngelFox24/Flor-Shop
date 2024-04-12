//
//  NavManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/10/23.
//

import Foundation
import SwiftUI

enum NavPathsEnum {
    case loginView
    case registrationView
    case customerView
    case customersForPaymentView
    case addCustomerView
    case paymentView
    case customerHistoryView
    
    static var allValues: [NavPathsEnum] {
        return [.loginView, .registrationView, .customerView, .customersForPaymentView, .addCustomerView, .paymentView, .customerHistoryView]
    }
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
        navPaths.append(NavPathsEnum.loginView)
    }
    func goToRegistrationView() {
        navPaths.append(NavPathsEnum.registrationView)
    }
    func goToCustomerView() {
        navPaths.append(NavPathsEnum.customerView)
    }
    func goToCustomerForPaymentView() {
        navPaths.append(NavPathsEnum.customersForPaymentView)
    }
    func goToAddCustomerView() {
        navPaths.append(NavPathsEnum.addCustomerView)
    }
    func goToPaymentView() {
        navPaths.append(NavPathsEnum.paymentView)
    }
    func goToCustomerHistoryView() {
        navPaths.append(NavPathsEnum.customerHistoryView)
    }
}
