//
//  LogInViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/08/23.
//

import Foundation

class AgregarViewModel: ObservableObject {
    @Published var logInFields: LogInFields = LogInFields()
    let managerRepository: ManagerRepository
    init(managerRepository: ProductRepository) {
        self.managerRepository = managerRepository
    }
    func resetValuesFields() {
        logInFields = LogInFields()
    }
    func fieldsTrue() {
        print("All value true")
        logInFields.userOrEmailEdited = true
        logInFields.passwordEdited = true
    }
    func addProduct(subsidiary: Subsidiary) -> Bool {
        fieldsTrue()
        return false
    }
    func urlEdited() {
        print("New work")
        editedFields.imageURLEdited = true
    }
    func createProduct() -> Product? {
        guard let quantityStock = Int(editedFields.quantityStock), let unitCost = Double(editedFields.unitCost), let unitPrice = Double(editedFields.unitPrice) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        return Product(id: UUID(), name: editedFields.productName, qty: quantityStock, unitCost: unitCost, unitPrice: unitPrice, expirationDate: editedFields.expirationDate, url: editedFields.imageUrl)
    }
    func isProductNameValid() -> Bool {
        return !editedFields.productName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    func isQuantityValid() -> Bool {
        guard let quantityStock = Int(editedFields.quantityStock) else {
            return false
        }
        return quantityStock < 0 ? false : true
    }
    func isUnitCostValid() -> Bool {
        guard let unitCost = Double(editedFields.unitCost) else {
            return false
        }
        return unitCost < 0.0 ? false : true
    }
    func isUnitPriceValid() -> Bool {
        guard let unitPrice = Double(editedFields.unitPrice) else {
            return false
        }
        return unitPrice < 0.0 ? false : true
    }
    func isExpirationDateValid() -> Bool {
        return true
    }
    func isURLValid() -> Bool {
        guard URL(string: editedFields.imageUrl) != nil else {
            return false
        }
        return true
    }
}
class LogInFields {
    var userOrEmail: String = ""
    var userOrEmailEdited: Bool = false
    var userOrEmailError: String {
        if userOrEmail == "" && userOrEmailEdited {
            return "Nombre de producto no válido"
        } else {
            return ""
        }
    }
    var password: String = ""
    var passwordEdited: Bool = false
    var passwordError: String {
        if passwordError == "" && passwordEdited {
            return "Contraseña no válido"
        } else {
            return ""
        }
    }
}
