//
//  AgregarViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/07/23.
//

import Foundation
import CoreGraphics
import ImageIO

class AgregarViewModel: ObservableObject {
    @Published var editedFields: FieldEditTemporal = FieldEditTemporal()
    private let saveProductUseCase: SaveProductUseCase
    init(saveProductUseCase: SaveProductUseCase) {
        self.saveProductUseCase = saveProductUseCase
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
    func addProduct() -> Bool {
        guard let product = createProduct() else {
            print("No se pudo crear producto")
            return false
        }
        let result = self.saveProductUseCase.execute(product: product)
        if result == "Success" {
            print("Se añadio correctamente")
            resetValuesFields()
            return true
        } else {
            print(result)
            editedFields.errorBD = result
            return false
        }
    }
    func editProduct(product: Product) {
        editedFields.productId = product.id
        editedFields.productName = product.name
        editedFields.imageUrl = product.image.imageUrl
        editedFields.quantityStock = String(product.qty)
        editedFields.unitCost = String(product.unitCost)
        editedFields.unitPrice = String(product.unitPrice)
        editedFields.errorBD = ""
    }
    func urlEdited() {
        print("New work")
        editedFields.imageURLEdited = true
    }
    
    func loadTestData() {
        if let path = Bundle.main.path(forResource: "BD_Flor_Shop", ofType: "csv", inDirectory: nil) {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let lines = content.components(separatedBy: "\n")
                var countSucc: Int = 0
                var countFail: Int = 0
                for line in lines {
                    let elements = line.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    if elements.count != 3 {
                        print("Count: \(elements.count)")
                        countFail = countFail + 1
                        continue
                    }
                    guard let price = Double(elements[2]) else {
                        print("Esta mal?: \(elements[2])")
                        countFail = countFail + 1
                        continue
                    }
                    let product = Product(id: UUID(), name: elements[1], qty: 10, unitCost: 2.0, unitPrice: price, expirationDate: nil, image: ImageUrl(id: UUID(), imageUrl: elements[0]))
                    let result = self.saveProductUseCase.execute(product: product)
                    if result == "Success" {
                        countSucc = countSucc + 1
                    } else {
                        countFail = countFail + 1
                    }
                }
                print("Total: \(lines.count), Success: \(countSucc), Fails: \(countFail)")
            } catch {
                print("Error al leer el archivo: \(error)")
            }
        } else {
            print("No se encuentra el archivo")
        }
    }
    
    func createProduct() -> Product? {
        guard let quantityStock = Int(editedFields.quantityStock), let unitCost = Double(editedFields.unitCost), let unitPrice = Double(editedFields.unitPrice) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        return Product(id: editedFields.productId ?? UUID(), name: editedFields.productName, qty: quantityStock, unitCost: unitCost, unitPrice: unitPrice, expirationDate: editedFields.expirationDate, image: ImageUrl(id: UUID(), imageUrl: editedFields.imageUrl))
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

class FieldEditTemporal {
    var productId: UUID?
    var errorBD: String = ""
    var productName: String = ""
    var productEdited: Bool = false
    var productError: String {
        print("editedP: \(productEdited)")
        if productName == "" && productEdited {
            return "Nombre de producto no válido"
        } else {
            return ""
        }
    }
    var expirationDate: Date?
    var expirationDateEdited: Bool = false
    var quantityStock: String = "0"
    var quantityEdited: Bool = false
    var quantityError: String {
        guard let quantityStockInt = Int(quantityStock) else {
            return "Debe ser número entero"
        }
        if quantityStockInt <= 0 && unitCostEdited {
            return "Debe ser mayor a 0: \(unitCostEdited)"
        } else {
            return ""
        }
    }
    var imageUrl: String = ""
    var imageURLEdited: Bool = false
    var imageURLError: String = ""
    var unitCost: String = "0"
    var unitCostEdited: Bool = false
    var unitCostError: String {
        guard let unitCostDouble = Double(unitCost) else {
            return "Debe ser número decimal o entero"
        }
        if unitCostDouble <= 0.0 && unitCostEdited {
            return "Debe ser mayor a 0: \(unitCostEdited)"
        } else {
            return ""
        }
    }
    var profitMarginEdited: Bool = false
    var unitPrice: String = "0"
    var unitPriceEdited: Bool = false
    var unitPriceError: String {
        guard let unitPriceDouble = Double(unitPrice) else {
            return "Debe ser número decimal o entero"
        }
        if unitPriceDouble <= 0.0 && unitPriceEdited {
            return "Debe ser mayor a 0: \(unitPriceEdited)"
        } else {
            return ""
        }
    }
    var profitMargin: String {
            guard let unitCost = Double(unitCost), let unitPrice = Double(unitPrice) else {
                return "0"
            }
            print("Se llamo a la propiedad calculada")
            if ((unitPrice - unitCost) > 0.0) && (unitPrice > 0) && (unitCost > 0) {
                return String(Int(((unitPrice - unitCost) / unitCost) * 100))
            } else {
                return "0"
            }
    }
}
