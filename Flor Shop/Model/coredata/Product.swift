//
//  Product.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation

struct Product: Identifiable{
    let id: UUID
    let name: String
    let qty: Double
    let unitCost: Double
    let unitPrice: Double
    let expirationDate: Date
    let type: String
    let url: String
    
    init(name: String, qty: Double, unitCost: Double, unitPrice: Double, expirationDate: Date, type: String, url: String) {
        self.id = UUID()
        self.name = name
        self.qty = qty
        self.unitCost = unitCost
        self.unitPrice = unitPrice
        self.expirationDate = expirationDate
        self.type = type
        self.url = url
    }
    
    
    //MARK: Validacion Crear Producto
    func isProductNameValid() -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func isCantidadValid() -> Bool {
        if type == "Uni"{
            if Int(qty) > 0 {
                return true
            } else {
                return false
            }
        }else if type == "Kg"{
            if qty > 0.0 {
                return true
            } else {
                return false
            }
        }else{
            return false
        }
    }
    
    func isCostoUnitarioValid() -> Bool {
        if  unitCost > 0.0 {
            return true
        } else {
            return false
        }
    }
    
    func isPrecioUnitarioValid() -> Bool {
        if unitPrice > 0.0 {
            return true
        } else {
            return false
        }
    }
    
    func isFechaVencimientoValid() -> Bool {
        return true
        /*let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // formato esperado de la fecha
        
        if dateFormatter.date(from: expirationDate) != nil {
            // la fecha se pudo transformar exitosamente
            return true
        } else {
            // la fecha no se pudo transformar
            return false
        } */
    }
    
    func isURLValid() -> Bool {
        guard URL(string: url) != nil else {
            return false
        }
        return true
    }
    
}
