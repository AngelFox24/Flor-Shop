//
//  AgregarViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/07/23.
//

import Foundation
import SwiftUI
import _PhotosUI_SwiftUI

class AgregarViewModel: ObservableObject {
    
    @Published var agregarFields = AgregarFields()
    @Published var isLoading: Bool = false
    
    private let saveProductUseCase: SaveProductUseCase
    let loadSavedImageUseCase: LoadSavedImageUseCase
    let saveImageUseCase: SaveImageUseCase
    
    init(saveProductUseCase: SaveProductUseCase, loadSavedImageUseCase: LoadSavedImageUseCase, saveImageUseCase: SaveImageUseCase) {
        self.saveProductUseCase = saveProductUseCase
        self.loadSavedImageUseCase = loadSavedImageUseCase
        self.saveImageUseCase = saveImageUseCase
    }
    //MARK: Funtions
    func releaseResources() {
        self.agregarFields = AgregarFields()
    }
    func findProductNameOnInternet() {
        if self.agregarFields.productName != "" {
            openGoogleImageSearch(nombre: self.agregarFields.productName)
            self.agregarFields.isPresented = false
        } else {
            self.agregarFields.productEdited = true
            self.agregarFields.isPresented = false
        }
    }
    func pasteFromInternet() {
        print("Se ejecuta pegar")
        if self.agregarFields.productName != "" {
            self.agregarFields.selectedLocalImage = nil
            self.agregarFields.imageUrl = pasteFromClipboard()
            print("Se pego imagen: \(self.agregarFields.imageUrl.description)")
        } else {
            self.agregarFields.productEdited = true
        }
    }
    func addProduct() async -> Bool {
        await MainActor.run {
            agregarFields.fieldsTrue()
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
                releaseResources()
            }
            return true
        } else {
            print(result)
            await MainActor.run {
                self.agregarFields.errorBD = result
            }
            return false
        }
    }
    func editProduct(product: Product) {
        if let imageId = product.image?.id {
            self.agregarFields.selectedLocalImage = self.loadSavedImageUseCase.execute(id: imageId)
            self.agregarFields.idImage = imageId
            print("Se agrego el id correctamente")
        }
        self.agregarFields.productId = product.id
        self.agregarFields.active = product.active
        self.agregarFields.productName = product.name
        self.agregarFields.imageUrl = product.image?.imageUrl ?? ""
        self.agregarFields.quantityStock = String(product.qty)
        self.agregarFields.unitCost = String(product.unitCost)
        self.agregarFields.unitPrice = String(product.unitPrice)
        self.agregarFields.errorBD = ""
    }
    func createProduct() -> Product? {
        guard let quantityStock = Int(self.agregarFields.quantityStock), let unitCost = Double(self.agregarFields.unitCost), let unitPrice = Double(self.agregarFields.unitPrice) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        if agregarFields.isErrorsEmpty() {
            return Product(id: self.agregarFields.productId ?? UUID(), active: self.agregarFields.active, name: self.agregarFields.productName, qty: quantityStock, unitCost: unitCost, unitPrice: unitPrice, expirationDate: self.agregarFields.expirationDate, image: getImageIfExist())
        } else {
            return nil
        }
    }
    func getImageIfExist() -> ImageUrl? {
        if let imageLocal = self.agregarFields.selectedLocalImage {
            return self.saveImageUseCase.execute(idImage: UUID(), image: imageLocal)
        } else if self.agregarFields.imageUrl != "" {
            return ImageUrl(id: UUID(), imageUrl: self.agregarFields.imageUrl, imageHash: "")
        } else {
            return nil
        }
    }
//    func loadTestData() {
//        if let path = Bundle.main.path(forResource: "BD_Flor_Shop", ofType: "csv", inDirectory: nil) {
//            do {
//                let content = try String(contentsOfFile: path, encoding: .utf8)
//                let lines = content.components(separatedBy: "\n")
//                var countSucc: Int = 0
//                var countFail: Int = 0
//                for line in lines {
//                    let elements = line.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//                    if elements.count != 3 {
//                        print("Count: \(elements.count)")
//                        countFail = countFail + 1
//                        continue
//                    }
//                    guard let price = Double(elements[2].replacingOccurrences(of: ",", with: "")) else {
//                        print("Esta mal?: \(elements[2])")
//                        countFail = countFail + 1
//                        continue
//                    }
//                    let product = Product(id: UUID(), active: true, name: elements[1], qty: 10, unitCost: 2.0, unitPrice: price, expirationDate: nil, image: ImageUrl(id: UUID(), imageUrl: elements[0], imageHash: ""))
//                    let result = self.saveProductUseCase.execute(product: product)
//                    if result == "Success" {
//                        countSucc = countSucc + 1
//                    } else {
//                        print("Error: \(result)")
//                        countFail = countFail + 1
//                    }
//                }
//                print("Total: \(lines.count), Success: \(countSucc), Fails: \(countFail)")
//            } catch {
//                print("Error al leer el archivo: \(error)")
//            }
//        } else {
//            print("No se encuentra el archivo")
//        }
//    }
}
//MARK: Fields
class AgregarFields {
    var isPresented: Bool = false
    var selectedLocalImage: UIImage?
    var selectionImage: PhotosPickerItem? = nil {
        didSet{
            setImage(from: selectionImage)
        }
    }
    var productId: UUID?
    var active: Bool = true
    var productName: String = ""
    var productEdited: Bool = false
    var productError: String {
        if productName == "" && productEdited {
            return "Nombre de producto no válido"
        } else {
            return ""
        }
    }
    var expirationDate: Date?
    var expirationDateEdited: Bool = false
    var quantityStock: String = ""
    var quantityEdited: Bool = false
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
    var idImage: UUID?
    var imageUrl: String = ""
    var imageURLEdited: Bool = false
    var imageURLError: String = ""
    var unitCost: String = ""
    var unitCostEdited: Bool = false
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
    var profitMarginEdited: Bool = false
    var unitPrice: String = ""
    var unitPriceEdited: Bool = false
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
    var errorBD: String = ""
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {return}
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
    }
    
    func fieldsTrue() {
        self.productEdited = true
        self.expirationDateEdited = true
        self.quantityEdited = true
        self.imageURLEdited = true
        self.unitCostEdited = true
        self.profitMarginEdited = true
        self.unitPriceEdited = true
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
}
