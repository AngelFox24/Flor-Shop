//
//  AgregarViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/07/23.
//

import Foundation

class AgregarViewModel: ObservableObject {
    @Published var editedFields: FieldEditTemporal = FieldEditTemporal()
    
    func resetValuesFields(){
        editedFields = FieldEditTemporal()
    }
}

class FieldEditTemporal{
    var productEdited:Bool = false
    var totalCostEdited:Bool = false
    var quantityEdited:Bool = false
    var imageURLEdited:Bool = false
    var imageURLError:String = ""
    var unitCostEdited:Bool = false
    var profitMarginEdited:Bool = false
    var unitPriceEdited:Bool = false
}

