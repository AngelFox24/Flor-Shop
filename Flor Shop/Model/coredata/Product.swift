//
//  Product.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation


extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

enum TipoMedicion: CustomStringConvertible {
    case Kg
    case Uni
    var description: String {
        switch self {
        case .Kg:
            return "Kilos"
        case .Uni:
            return "Unidades"
        }
    }
    
    static var allValues: [TipoMedicion] {
        return [.Kg, .Uni]
    }
    
    static func from(description: String) -> TipoMedicion? {
        for case let tipo in TipoMedicion.allValues {
            if tipo.description == description {
                return tipo
            }
        }
        return nil
    }
}

struct Product: Identifiable{
    var id: UUID
    var name: String
    var qty: Double
    var unitCost: Double
    var unitPrice: Double
    var expirationDate: Date
    var type: TipoMedicion
    var url: String
    var totalCost: Double
    var profitMargin: Double
    var keyWords: String
    var replaceImage: Bool
    
    init(id: UUID, name: String, qty: Double, unitCost: Double, unitPrice: Double, expirationDate: Date, type: TipoMedicion, url: String, replaceImage: Bool) {
        self.id = id
        self.name = name
        self.qty = qty
        self.unitCost = unitCost
        self.unitPrice = unitPrice
        self.expirationDate = expirationDate
        self.type = type
        self.url = url
        self.totalCost = 0
        self.profitMargin = 0
        self.keyWords = "Producto"
        self.replaceImage = replaceImage
    }
    init () {
        self.id = UUID()
        self.name = ""
        self.qty = 0.0
        self.unitCost = 0.0
        self.unitPrice = 0.0
        self.expirationDate = Date()
        self.type = .Uni
        self.url = ""
        self.totalCost = 0.0
        self.profitMargin = 0.0
        self.keyWords = "Producto"
        self.replaceImage = false
        print ("Se creo un producto vacio")
    }
    
    //MARK: Validacion Crear Producto
    func isProductNameValid() -> Bool {
        print ("El nombre en Product es name: \(self.name)")
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func isCantidadValid() -> Bool {
        if type == .Uni{
            if Int(qty) > 0 {
                return true
            } else {
                return false
            }
        }else if type == .Kg{
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
    }
    
    func isURLValid() -> Bool {
        guard URL(string: url) != nil else {
            return false
        }
        return true
    }
    
}
