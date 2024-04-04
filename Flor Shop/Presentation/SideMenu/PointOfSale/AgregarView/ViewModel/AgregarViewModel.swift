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
    @Published var productId: UUID?
    @Published var active: Bool = true
    @Published var productName: String = ""
    @Published var productEdited: Bool = false
    var productError: String {
        if productName == "" && productEdited {
            return "Nombre de producto no válido"
        } else {
            return ""
        }
    }
    @Published var expirationDate: Date?
    @Published var expirationDateEdited: Bool = false
    @Published var quantityStock: String = "0"
    @Published var quantityEdited: Bool = false
    var quantityError: String {
        guard let quantityInt = Int(quantityStock) else {
            return "Cantidad debe ser número entero"
        }
        if quantityInt < 0 && quantityEdited {
            return "Cantidad debe ser mayor a 0: \(quantityEdited)"
        } else {
            return ""
        }
    }
    @Published var imageUrl: String = ""
    @Published var imageURLEdited: Bool = false
    @Published var imageURLError: String = ""
    @Published var unitCost: String = "0"
    @Published var unitCostEdited: Bool = false
    var unitCostError: String {
        guard let unitCostDouble = Double(unitCost) else {
            return "Costo debe ser número decimal o entero"
        }
        if unitCostDouble <= 0.0 && unitCostEdited {
            return "Costo debe ser mayor a 0: \(unitCostEdited)"
        } else {
            return ""
        }
    }
    @Published var profitMarginEdited: Bool = false
    @Published var unitPrice: String = "0"
    @Published var unitPriceEdited: Bool = false
    var unitPriceError: String {
        guard let unitPriceDouble = Double(unitPrice) else {
            return "Precio debe ser número decimal o entero"
        }
        if unitPriceDouble <= 0.0 && unitPriceEdited {
            return "Precio debe ser mayor a 0: \(unitPriceEdited)"
        } else {
            return ""
        }
    }
    var profitMargin: String {
            guard let unitCost = Double(unitCost), let unitPrice = Double(unitPrice) else {
                return "0 %"
            }
            if ((unitPrice - unitCost) > 0.0) && (unitPrice > 0) && (unitCost > 0) {
                return String(Int(((unitPrice - unitCost) / unitCost) * 100)) + " %"
            } else {
                return "0 %"
            }
    }
    @Published var errorBD: String = ""
    
    private let saveProductUseCase: SaveProductUseCase
    
    init(saveProductUseCase: SaveProductUseCase) {
        self.saveProductUseCase = saveProductUseCase
    }
    //MARK: Funciones
    func resetValuesFields() {
        fieldsFalse()
        self.productId = nil
        self.active = true
        self.productName = ""
        self.expirationDate = nil
        self.quantityStock = "0"
        self.imageUrl = ""
        self.imageURLError = ""
        self.unitCost = "0"
        self.unitPrice = "0"
        self.errorBD = ""
    }
    func fieldsTrue() {
        print("All value true")
        self.productEdited = true
        self.active = true
        self.expirationDateEdited = true
        self.quantityEdited = true
        self.imageURLEdited = true
        self.unitCostEdited = true
        self.profitMarginEdited = true
        self.unitPriceEdited = true
    }
    func fieldsFalse() {
        print("All value false")
        self.productEdited = false
        self.expirationDateEdited = false
        self.quantityEdited = false
        self.imageURLEdited = false
        self.unitCostEdited = false
        self.profitMarginEdited = false
        self.unitPriceEdited = false
    }
    func addProduct() -> Bool {
        fieldsTrue()
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
            self.errorBD = result
            return false
        }
    }
    func editProduct(product: Product) {
        self.productId = product.id
        self.productName = product.name
        self.imageUrl = product.image.imageUrl
        self.quantityStock = String(product.qty)
        self.unitCost = String(product.unitCost)
        self.unitPrice = String(product.unitPrice)
        self.errorBD = ""
    }
    func urlEdited() {
        self.imageURLEdited = true
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
                    let product = Product(id: UUID(), active: true, name: elements[1], qty: 10, unitCost: 2.0, unitPrice: price, expirationDate: nil, image: ImageUrl(id: UUID(), imageUrl: elements[0]))
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
        guard let quantityStock = Int(self.quantityStock), let unitCost = Double(self.unitCost), let unitPrice = Double(self.unitPrice) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        if isErrorsEmpty() {
            return Product(id: self.productId ?? UUID(), active: self.active, name: self.productName, qty: quantityStock, unitCost: unitCost, unitPrice: unitPrice, expirationDate: self.expirationDate, image: ImageUrl(id: UUID(), imageUrl: self.imageUrl))
        } else {
            return nil
        }
    }
    func isErrorsEmpty() -> Bool {
        //let validationResult = validateImageURL()
        //print("Terminó la validación: \(validationResult)")
        //self.imageURLError = validationResult
        //print("Se ejecuta la verificación de errores")
        
        let isEmpty = self.productError.isEmpty &&
                      self.imageURLError.isEmpty &&
                      self.errorBD.isEmpty &&
                      self.quantityError.isEmpty &&
                      self.unitCostError.isEmpty &&
                      self.unitPriceError.isEmpty
        
        return isEmpty
    }
    func isProductNameValid() -> Bool {
        return !self.productName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    func isQuantityValid() -> Bool {
        guard let quantityStock = Int(self.quantityStock) else {
            return false
        }
        if quantityStock < 0 {
            return false
        } else {
            return true
        }
    }
    func isUnitCostValid() -> Bool {
        guard let unitCost = Double(self.unitCost) else {
            return false
        }
        return unitCost < 0.0 ? false : true
    }
    func isUnitPriceValid() -> Bool {
        guard let unitPrice = Double(self.unitPrice) else {
            return false
        }
        return unitPrice < 0.0 ? false : true
    }
    func isExpirationDateValid() -> Bool {
        return true
    }
    func isURLValid() -> Bool {
        guard URL(string: self.imageUrl) != nil else {
            return false
        }
        return true
    }
    func validateImageURL() async -> String {
        let maxSizeInKB: Int = 10
        let maxResolutionInMP: Int = 10
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        guard let url = URL(string: self.imageUrl) else {
            return "La URL de la imagen no es válida"
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let mimeType = response.mimeType, mimeType.hasPrefix("image") else {
                return "No es una imagen"
            }
            
            let fileSize = data.count
            if fileSize > maxSizeInKB * 1024 {
                return "La imagen es demasiado pesada"
            }
            
            if let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
               let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
               let pixelWidth = properties[kCGImagePropertyPixelWidth] as? Int,
               let pixelHeight = properties[kCGImagePropertyPixelHeight] as? Int {
                let megapixels = (pixelWidth * pixelHeight) / (1_000_000)
                if megapixels > maxResolutionInMP {
                    return "La imagen es muy grande"
                }
            }
        } catch {
            return "Ocurrio un error al validar la imagen"
        }
        return ""
    }
}
