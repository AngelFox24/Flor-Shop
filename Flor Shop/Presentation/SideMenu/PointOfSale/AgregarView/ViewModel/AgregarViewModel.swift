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
    @Published var selectedLocalImage: UIImage?
    @Published var selectionImage: PhotosPickerItem? = nil {
        didSet{
            setImage(from: selectionImage)
        }
    }
    
    private let saveProductUseCase: SaveProductUseCase
    let saveImageUseCase: SaveImageUseCase
    let exportProductsUseCase: ExportProductsUseCase
    
    init(
        saveProductUseCase: SaveProductUseCase,
        saveImageUseCase: SaveImageUseCase,
        exportProductsUseCase: ExportProductsUseCase
    ) {
        self.saveProductUseCase = saveProductUseCase
        self.saveImageUseCase = saveImageUseCase
        self.exportProductsUseCase = exportProductsUseCase
    }
    //MARK: Funtions
    func releaseResources() {
        self.agregarFields = AgregarFields()
    }
    func findProductNameOnInternet() {
        if self.agregarFields.productName != "" {
            openGoogleImageSearch(nombre: self.agregarFields.productName)
        } else {
            self.agregarFields.productEdited = true
        }
    }
    func pasteFromInternet() {
        print("Se ejecuta pegar")
        if self.agregarFields.productName != "" {
            self.selectedLocalImage = nil
            self.agregarFields.imageUrl = pasteFromClipboard()
            print("Se pego imagen: \(self.agregarFields.imageUrl.description)")
        } else {
            self.agregarFields.productEdited = true
        }
    }
    func addProduct() async throws {
        await MainActor.run {
            fieldsTrue()
        }
        guard let product = try await createProduct() else {
            print("No se pudo crear producto")
            throw LocalStorageError.notFound("No se pudo crear el producto")
        }
        try await self.saveProductUseCase.execute(product: product)
        await MainActor.run {
            releaseResources()
        }
    }
    func fieldsTrue() {
        self.agregarFields.productEdited = true
        self.agregarFields.expirationDateEdited = true
        self.agregarFields.quantityEdited = true
        self.agregarFields.imageURLEdited = true
        self.agregarFields.unitCostEdited = true
        self.agregarFields.profitMarginEdited = true
        self.agregarFields.unitPriceEdited = true
    }
    func editProduct(product: Product) async throws {
        print("Se edito producto: \(product.name)")
        await MainActor.run {
            self.agregarFields.idImage = product.image?.id
            self.agregarFields.productId = product.id
            self.agregarFields.active = product.active
            self.agregarFields.productName = product.name
            self.agregarFields.imageUrl = product.image?.imageUrl ?? ""
            self.agregarFields.quantityStock = String(product.qty)
            self.agregarFields.unitType = product.unitType
            self.agregarFields.unitCost = product.unitCost.cents
            self.agregarFields.unitPrice = product.unitPrice.cents
            self.agregarFields.scannedCode = product.barCode == nil ? "" : product.barCode!
            self.agregarFields.errorBD = ""
        }
        if let imageUrl = product.image {
            let uiImage = try? await LocalImageManagerImpl.loadImage(image: imageUrl)
            await MainActor.run {
                self.selectedLocalImage = uiImage
            }
        }
        print("Se verifica producto: \(self.agregarFields.productName)")
    }
    func createProduct() async throws -> Product? {
        guard let quantityStock = Int(self.agregarFields.quantityStock) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        if agregarFields.isErrorsEmpty() {
            return Product(
                id: self.agregarFields.productId ?? UUID(),
                active: self.agregarFields.active,
                barCode: self.agregarFields.scannedCode == "" ? nil : self.agregarFields.scannedCode,
                name: self.agregarFields.productName,
                qty: quantityStock,
                unitType: self.agregarFields.unitType,
                unitCost: Money(self.agregarFields.unitCost),
                unitPrice: Money(self.agregarFields.unitPrice),
                expirationDate: self.agregarFields.expirationDate,
                image: try await getImageIfExist(),
                createdAt: Date(),
                updatedAt: Date()
            )
        } else {
            return nil
        }
    }
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {return}
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    print("Imagen vacia")
                    return
                }
                let imagen = try await LocalImageManagerImpl.getEfficientImage(uiImage: uiImage)
                await MainActor.run {
                    print("Se le asigno la imagen")
                    self.selectedLocalImage = imagen
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    func exportCSV(url: URL) {
        self.exportProductsUseCase.execute(url: url)
    }
    func importCSV() async -> Bool {
        return true
    }
    func getImageIfExist() async throws -> ImageUrl? {
        if let uiImage = self.selectedLocalImage {
            return try await self.saveImageUseCase.execute(uiImage: uiImage)
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
struct AgregarFields {
    var isShowingPicker = false
    var isShowingScanner = false
    var productId: UUID?
    var scannedCode: String = ""
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
    var unitType: UnitTypeEnum = .unit
    var unitCost: Int = 0
    var unitCostEdited: Bool = false
    var unitCostError: String {
        if unitCostEdited {
            if unitCost <= 0 && unitCostEdited {
                return "Costo debe ser mayor a 0"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    var profitMarginEdited: Bool = false
    var unitPrice: Int = 0
    var unitPriceEdited: Bool = false
    var unitPriceError: String {
        if unitPriceEdited {
            if unitPrice <= 0 {
                return "Precio debe ser mayor a 0"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    var profitMargin: String {
            if ((unitPrice - unitCost) > 0) && (unitPrice > 0) && (unitCost > 0) {
                return String(Int(((unitPrice - unitCost) / unitCost) * 100)) + " %"
            } else {
                return "0 %"
            }
    }
    var errorBD: String = ""
    
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
