//
//  Focus.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 09/08/2024.
//

import Foundation

enum AllFocusFields: Hashable {
    case agregar(AgregarFocusFields)
    case products(ProductsFocusFields)
    case employees(EmployeesFocusFields)
    case customers(CustomersFocusFields)
    case addCustomer(AddCustomerFocusFields)
    case logIn(LogInFocusFields)
}

enum ProductsFocusFields {
    case searchBar
}

enum EmployeesFocusFields {
    case searchBar
}

enum CustomersFocusFields {
    case searchBar
}

enum AgregarFocusFields {
    case barcode
    case productName
    case disponible
    case quantity
    case unitCost
    case unitPrice
    case margin
}

enum AddCustomerFocusFields {
    case nombre
    case apellidos
    case movil
    case deudaTotal
    case fechalimite
    case diascredito
    case limitecredito
}

enum LogInFocusFields {
    case user
    case password
}
