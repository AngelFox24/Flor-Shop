//
//  AgregarViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/07/23.
//

import Foundation

class AgregarViewModel: ObservableObject {
    @Published var editedFields: FieldEditTemporal = FieldEditTemporal()
    let productRepository: ProductRepository
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    func resetValuesFields() {
        editedFields = FieldEditTemporal()
    }
    func fieldsTrue() {
        print("All value true")
        editedFields.productEdited = true
        editedFields.expirationDateEdited = true
        editedFields.quantityEdited = true
        editedFields.imageURLEdited = true
        editedFields.imageURLError = ""
        editedFields.unitCostEdited = true
        editedFields.profitMarginEdited = true
        editedFields.unitPriceEdited = true
    }
    func addProduct(subsidiary: Subsidiary) -> Bool {
        guard let product = createProduct() else {
            print("No se pudo crear producto")
            return false
        }
        let result = productRepository.saveProduct(product: product, subsidiary: subsidiary)
        if result == "Success" {
            print("Se añadio correctamente")
            resetValuesFields()
            return true
        } else {
            print(result)
            return false
        }
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
}
class FieldEditTemporal {
    var productName: String = ""
    var productEdited: Bool = false
    var expirationDate: Date?
    var expirationDateEdited: Bool = false
    var quantityStock: String = ""
    var quantityEdited: Bool = false
    var imageUrl: String = ""
    var imageURLEdited: Bool = false
    var imageURLError: String = ""
    var unitCost: String = ""
    var unitCostEdited: Bool = false
    var profitMarginEdited: Bool = false
    var unitPrice: String = ""
    var unitPriceEdited: Bool = false
}
