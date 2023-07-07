//
//  Product.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation
import CoreGraphics
import ImageIO

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

enum MeasurementType: CustomStringConvertible {
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
    
    static var allValues: [MeasurementType] {
        return [.Kg, .Uni]
    }
    
    static func from(description: String) -> MeasurementType? {
        for case let type in MeasurementType.allValues {
            if type.description == description {
                return type
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
    var type: MeasurementType
    var url: String
    var totalCost: Double
    var profitMargin: Double
    var keyWords: String
    var replaceImage: Bool
    
    init(id: UUID, name: String, qty: Double, unitCost: Double, unitPrice: Double, expirationDate: Date, type: MeasurementType, url: String, replaceImage: Bool) {
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
    }
    
    //MARK: Validacion Crear Producto
    func isProductNameValid() -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func isQuantityValid() -> Bool {
        if type == .Uni{
            print ("Tipo Unidades")
            if qty.truncatingRemainder(dividingBy: 1) != 0{
                //Tiene Decimales
                print ("WTF \(qty)")
                return false
            } else {
                return true
            }
        }else if type == .Kg{
            if qty > 0.0 {
                print ("Tipo Kilos")
                return true
            } else {
                return false
            }
        }else{
            return false
        }
    }
    
    func isUnitCostValid() -> Bool {
        if  unitCost > 0.0 {
            return true
        } else {
            return false
        }
    }
    
    func isUnitPriceValid() -> Bool {
        if unitPrice > 0.0 {
            return true
        } else {
            return false
        }
    }
    
    func isExpirationDateValid() -> Bool {
        return true
    }
    
    func isURLValid() -> Bool {
        guard URL(string: url) != nil else {
            return false
        }
        return true
    }
    
    func validateImageURL(urlString: String, completion: @escaping (Bool) -> Void) {
        let maxSizeInKB: Int = 10
        let maxResolutionInMP: Int = 10
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                completion(false)
                return
            }
            
            guard let mimeType = response?.mimeType, mimeType.hasPrefix("image") else {
                completion(false)
                return
            }
            
            let fileSize = data.count
            if fileSize > maxSizeInKB * 1024 {
                completion(false)
                return
            }
            
            if let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
               let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
               let pixelWidth = properties[kCGImagePropertyPixelWidth] as? Int,
               let pixelHeight = properties[kCGImagePropertyPixelHeight] as? Int {
                
                let megapixels = (pixelWidth * pixelHeight) / (1_000_000)
                if megapixels > maxResolutionInMP {
                    completion(false)
                    return
                }
            }
            
            completion(true)
        }
        
        task.resume()
    }
    
}
