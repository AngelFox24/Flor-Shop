//
//  AddCusterViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 14/10/23.
//

import Foundation

class AddCustomerViewModel: ObservableObject {
    @Published var fieldsAddCustomer: FieldsAddCustomer = FieldsAddCustomer()
    let saveCustomerUseCase: SaveCustomerUseCase
    
    init(saveCustomerUseCase: SaveCustomerUseCase) {
        self.saveCustomerUseCase = saveCustomerUseCase
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
        let result = self.saveCustomerUseCase.execute(customer: customer)
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
        guard let creditLimitDouble = Double(fieldsAddCustomer.creditLimit) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        return Customer(id: fieldsAddCustomer.id ?? UUID(), name: fieldsAddCustomer.name, lastName: fieldsAddCustomer.lastname, image: ImageUrl.getDummyImage(), active: true, creditLimit: creditLimitDouble, isCreditLimit: false, isDateLimit: false, creditScore: fieldsAddCustomer.creditScore, dateLimit: Date(), phoneNumber: fieldsAddCustomer.phoneNumber, totalDebt: totalDebt, isCreditLimitActive: fieldsAddCustomer.creditLimitFlag, isDateLimitActive: fieldsAddCustomer.dateLimitFlag)
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
    //TODO: Cambiar de Fecha a dias de Credito, luego calcular fecha
    var dateLimit: Date = Date()
    var dateLimitEdited: Bool = false
    var dateLimitFlag: Bool = false
    var creditLimit: String = "100"
    var creditScore: Int = 50
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
