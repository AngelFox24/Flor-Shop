//
//  AgregarViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/07/23.
//

import Foundation
import SwiftUI
import CoreGraphics
import ImageIO
import _PhotosUI_SwiftUI

class AgregarViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isPresented: Bool = false
    @Published var selectedLocalImage: UIImage?
    @Published var selectionImage: PhotosPickerItem? = nil {
        didSet{
            setImage(from: selectionImage)
        }
    }
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
    @Published var quantityStock: String = ""
    @Published var quantityEdited: Bool = false
    var quantityError: String {
        if quantityEdited {
            guard let quantityInt = Int(quantityStock) else {
                return "Cantidad debe ser número entero"
            }
            if quantityInt < 0 && quantityEdited {
                return "Cantidad debe ser mayor a 0"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    @Published var idImage: UUID?
    @Published var imageUrl: String = ""
    @Published var imageURLEdited: Bool = false
    @Published var imageURLError: String = ""
    @Published var unitCost: String = ""
    @Published var unitCostEdited: Bool = false
    var unitCostError: String {
        if unitCostEdited {
            guard let unitCostDouble = Double(unitCost) else {
                return "Costo debe ser número decimal o entero"
            }
            if unitCostDouble <= 0.0 && unitCostEdited {
                return "Costo debe ser mayor a 0"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    @Published var profitMarginEdited: Bool = false
    @Published var unitPrice: String = ""
    @Published var unitPriceEdited: Bool = false
    var unitPriceError: String {
        if unitPriceEdited {
            guard let unitPriceDouble = Double(unitPrice) else {
                return "Precio debe ser número decimal o entero"
            }
            if unitPriceDouble <= 0.0 {
                return "Precio debe ser mayor a 0"
            } else {
                return ""
            }
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
    let loadSavedImageUseCase: LoadSavedImageUseCase
    let saveImageUseCase: SaveImageUseCase
    
    init(saveProductUseCase: SaveProductUseCase, loadSavedImageUseCase: LoadSavedImageUseCase, saveImageUseCase: SaveImageUseCase) {
        self.saveProductUseCase = saveProductUseCase
        self.loadSavedImageUseCase = loadSavedImageUseCase
        self.saveImageUseCase = saveImageUseCase
    }
    //MARK: Funciones
    func resetValuesFields() {
        self.selectedLocalImage = nil
        self.selectionImage = nil
        self.isPresented = false
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
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {return}
        self.isLoading = true
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    print("Imagen vacia")
                    return
                }
                //selectedImage = uiImage
                //TODO: Save image with id
                await MainActor.run {
                    isPresented = false
                    selectedLocalImage = uiImage
                }
            } catch {
                print("Error: \(error)")
            }
        }
        self.isLoading = false
    }
    func findProductNameOnInternet() {
        if self.productName != "" {
            openGoogleImageSearch(nombre: self.productName)
            self.isPresented = false
        } else {
            self.productEdited = true
            self.isPresented = false
        }
    }
    func pasteFromInternet() {
        print("Se ejecuta pegar")
        if self.productName != "" {
            self.selectedLocalImage = nil
            self.imageUrl = pasteFromClipboard()
            print("Se pego imagen: \(self.imageUrl.description)")
        } else {
            self.productEdited = true
        }
    }
    func fieldsTrue() {
        print("All value true")
        self.productEdited = true
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
    func addProduct() async -> Bool {
        await MainActor.run {
            fieldsTrue()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        guard let product = createProduct() else {
            print("No se pudo crear producto")
            return false
        }
        let result = self.saveProductUseCase.execute(product: product)
        if result == "Success" {
            print("Se añadio correctamente")
            await MainActor.run {
                resetValuesFields()
            }
            return true
        } else {
            print(result)
            await MainActor.run {
                self.errorBD = result
            }
            return false
        }
    }
    func editProduct(product: Product) {
        if let imageId = product.image?.id {
            self.selectedLocalImage = self.loadSavedImageUseCase.execute(id: imageId)
            self.idImage = imageId
            print("Se agrego el id correctamente")
        }
        self.productId = product.id
        self.active = product.active
        self.productName = product.name
        self.imageUrl = product.image?.imageUrl ?? ""
        self.quantityStock = String(product.qty)
        self.unitCost = String(product.unitCost)
        self.unitPrice = String(product.unitPrice)
        self.errorBD = ""
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
                    let product = Product(id: UUID(), active: true, name: elements[1], qty: 10, unitCost: 2.0, unitPrice: price, expirationDate: nil, image: ImageUrl(id: UUID(), imageUrl: elements[0], imageHash: ""))
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
            return Product(id: self.productId ?? UUID(), active: self.active, name: self.productName, qty: quantityStock, unitCost: unitCost, unitPrice: unitPrice, expirationDate: self.expirationDate, image: saveSelectedImage())
        } else {
            return nil
        }
    }
    func saveSelectedImage() -> ImageUrl? {
        if let imageLocal = self.selectedLocalImage {
            guard let idImage = self.idImage else {
                print("Se crea nuevo id")
                let newIdImage = UUID()
                let imageHash = self.saveImageUseCase.execute(id: newIdImage, image: imageLocal, resize: true)
                return ImageUrl(id: newIdImage, imageUrl: "", imageHash: imageHash)
            }
            print("Se usa el mismo id")
            let imageHash = self.saveImageUseCase.execute(id: idImage, image: imageLocal, resize: true)
            return ImageUrl(id: idImage, imageUrl: "", imageHash: imageHash)
        } else if self.imageUrl != "" {
            return ImageUrl(id: UUID(), imageUrl: self.imageUrl, imageHash: "")
        } else {
            return nil
        }
    }
    func isErrorsEmpty() -> Bool {
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
}
