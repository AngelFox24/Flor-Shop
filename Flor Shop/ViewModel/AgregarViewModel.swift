//
//  AgregarViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/07/23.
//

import Foundation

class AgregarViewModel: ObservableObject {
    @Published var editedFields: FieldEditTemporal = FieldEditTemporal()
    func resetValuesFields() {
        editedFields = FieldEditTemporal()
    }
    func fieldsTrue() {
        print("All value true")
        editedFields.productEdited = true
        editedFields.totalCostEdited = true
        editedFields.quantityEdited = true
        editedFields.imageURLEdited = true
        editedFields.imageURLError = ""
        editedFields.unitCostEdited = true
        editedFields.profitMarginEdited = true
        editedFields.unitPriceEdited = true
    }
    func urlEdited() {
        print("New work")
        editedFields.imageURLEdited = true
    }
}
class FieldEditTemporal {
    var productEdited: Bool = false
    var totalCostEdited: Bool = false
    var quantityEdited: Bool = false
    var imageURLEdited: Bool = false
    var imageURLError: String = ""
    var unitCostEdited: Bool = false
    var profitMarginEdited: Bool = false
    var unitPriceEdited: Bool = false
}
