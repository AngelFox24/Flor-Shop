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
    let getImageUseCase: GetImageUseCase
    let exportProductsUseCase: ExportProductsUseCase
    let importProductsUseCase: ImportProductsUseCase
    //MARK: Init
    init(
        saveProductUseCase: SaveProductUseCase,
        getImageUseCase: GetImageUseCase,
        exportProductsUseCase: ExportProductsUseCase,
        importProductsUseCase: ImportProductsUseCase
    ) {
        self.saveProductUseCase = saveProductUseCase
        self.getImageUseCase = getImageUseCase
        self.exportProductsUseCase = exportProductsUseCase
        self.importProductsUseCase = importProductsUseCase
    }
    //MARK: Funtions
    func releaseResources() {
        self.selectedLocalImage = nil
        self.agregarFields = AgregarFields()
    }
    func findProductNameOnInternet() {
        if self.agregarFields.productName != "" {
            openGoogleImageSearch(nombre: self.agregarFields.productName)
        } else {
            self.agregarFields.productEdited = true
        }
    }
    func pasteFromInternet() async throws {
        print("Se ejecuta pegar")
        if self.agregarFields.productName != "" {
            let urlPasted = pasteFromClipboard()
//            LocalImageManagerImpl.loadImage(image: imageUrl)
            if let url = URL(string: urlPasted) {
                let imageDataTreated = try await LocalImageManagerImpl.getEfficientImageTreated(url: url)
                let uiImageTreated = try LocalImageManagerImpl.getUIImage(data: imageDataTreated)
                let imageHash = LocalImageManagerImpl.generarHash(data: imageDataTreated)
                await MainActor.run {
                    print("Se le asigno la imagen")
                    self.agregarFields.imageUrl = urlPasted
                    self.agregarFields.imageHash = imageHash
                    self.agregarFields.idImage = nil
                    self.selectedLocalImage = uiImageTreated
                }
            } else {
                print("NO es URL")
            }
            print("Se pego imagen: \(self.agregarFields.imageUrl.description)")
        } else {
            await MainActor.run {
                self.agregarFields.productEdited = true
            }
        }
    }
    func addProduct() async throws {
        await MainActor.run {
            fieldsTrue()
        }
        guard let product = try await createProduct() else {
            print("No se pudo crear producto")
            throw LocalStorageError.saveFailed("No se pudo crear el producto")
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
        await MainActor.run {
            self.agregarFields.idImage = product.image?.id
            self.agregarFields.productId = product.id
            self.agregarFields.active = product.active
            self.agregarFields.productName = product.name
            self.agregarFields.imageUrl = product.image?.imageUrl ?? ""
            self.agregarFields.quantityStock = String(product.qty)
            self.agregarFields.unitType = product.unitType
            print("UnitCost: \(product.unitCost.cents)")
            self.agregarFields.unitCost = product.unitCost.cents
            print("UnitPrice: \(product.unitPrice.cents)")
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
                productId: self.agregarFields.productId ?? nil,
                active: self.agregarFields.active,
                barCode: self.agregarFields.scannedCode == "" ? nil : self.agregarFields.scannedCode,
                name: self.agregarFields.productName,
                qty: quantityStock,
                unitType: self.agregarFields.unitType,
                unitCost: Money(self.agregarFields.unitCost),
                unitPrice: Money(self.agregarFields.unitPrice),
                expirationDate: self.agregarFields.expirationDate,
                image: try await getImageIfExist()
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
                let imageDataTreated = try await LocalImageManagerImpl.getEfficientImageTreated(image: uiImage)
                let uiImageTreated = try LocalImageManagerImpl.getUIImage(data: imageDataTreated)
                await MainActor.run {
                    print("Se le asigno la imagen")
                    self.agregarFields.imageUrl = ""
                    self.selectedLocalImage = uiImageTreated
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    func exportCSV(url: URL) async {
        await self.exportProductsUseCase.execute(url: url)
    }
    func importCSV(url: URL) async {
        await self.importProductsUseCase.execute(url: url)
    }
    func getImageIfExist() async throws -> ImageUrl? {
        //Verificar si hay URL, se da prioridad
        if self.agregarFields.imageUrl != "" {
            //Devolver ImageUrl nuevo
            print("[AgregarViewModel] Imagen URL no es vacia")
            return ImageUrl(
                id: self.agregarFields.idImage ?? UUID(),
                imageUrlId: self.agregarFields.idImage ?? nil,
                imageUrl: self.agregarFields.imageUrl,
                imageHash: self.agregarFields.imageHash
            )
        } else if let uiImage = self.selectedLocalImage {
            print("[AgregarViewModel] Hay UIImage")
            return try await self.getImageUseCase.execute(uiImage: uiImage)
        } else {
            return nil
        }
    }
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
    var imageHash: String = ""
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
