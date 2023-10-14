//
//  AddCusterViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 14/10/23.
//

import Foundation

class AddCustomerViewModel: ObservableObject {
    @Published var fieldsAddCustomer: FieldsAddCustomer = FieldsAddCustomer()
    let customerRepository: CustomerRepository
    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }
    func resetValuesFields() {
        fieldsAddCustomer = FieldsAddCustomer()
    }
    func fieldsTrue() {
        print("All value true")
        fieldsAddCustomer.nameEdited = true
        fieldsAddCustomer.lastnameEdited = true
        fieldsAddCustomer.phoneNumberEdited = true
        fieldsAddCustomer.dateLimitEdited = true
        fieldsAddCustomer.creditLimitEdited = true
    }
    func editCustomer(customer: Customer) {
        if let creditLimitUn = customer.creditLimit, let dateLimitUn = customer.dateLimit {
            fieldsAddCustomer.creditLimit = String(creditLimitUn)
            fieldsAddCustomer.creditLimitFlag = true
            fieldsAddCustomer.dateLimit = dateLimitUn
            fieldsAddCustomer.dateLimitFlag = true
        }
        fieldsAddCustomer.id = customer.id
        fieldsAddCustomer.name = customer.name
        fieldsAddCustomer.lastname = customer.lastName
        fieldsAddCustomer.phoneNumber = customer.phoneNumber
        fieldsAddCustomer.totalDebt = String(customer.totalDebt)
    }
    func addCustomer() -> Bool {
        guard let customer = createCustomer() else {
            print("No se pudo crear Cliente")
            return false
        }
        let result = customerRepository.addCustomer(customer: customer)
        if result == "" {
            print("Se añadio correctamente")
            resetValuesFields()
            return true
        } else {
            print(result)
            fieldsAddCustomer.errorBD = result
            return false
        }
    }
    func createCustomer() -> Customer? {
        guard let totalDebt = Double(fieldsAddCustomer.totalDebt) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        return Customer(id: fieldsAddCustomer.id ?? UUID(), name: fieldsAddCustomer.name, lastName: fieldsAddCustomer.lastname, image: ImageUrl.getDummyImage(), active: true, phoneNumber: fieldsAddCustomer.phoneNumber, totalDebt: totalDebt)
    }
}

class FieldsAddCustomer {
    var id: UUID?
    var name: String = ""
    var nameEdited: Bool = false
    var nameError: String {
        if name == "" && nameEdited {
            return "Nombre de cliente no válido"
        } else {
            return ""
        }
    }
    var lastname: String = ""
    var lastnameEdited: Bool = false
    var lastnameError: String {
        if lastname == "" && lastnameEdited {
            return "Apellido del cliente no válido"
        } else {
            return ""
        }
    }
    var phoneNumber: String = ""
    var phoneNumberEdited: Bool = false
    var totalDebt: String = "0"
    var dateLimit: Date = Date()
    var dateLimitEdited: Bool = false
    var dateLimitFlag: Bool = false
    var creditLimit: String = "0"
    var creditLimitEdited: Bool = false
    var creditLimitFlag: Bool = false
    var creditLimitError: String {
        guard let creditLimitDouble = Double(creditLimit) else {
            return "Debe ser número decimal o entero"
        }
        if creditLimitDouble <= 0 && creditLimitEdited {
            return "Debe ser mayor a 0: \(creditLimitEdited)"
        } else {
            return ""
        }
    }
    var errorBD: String = ""
}
