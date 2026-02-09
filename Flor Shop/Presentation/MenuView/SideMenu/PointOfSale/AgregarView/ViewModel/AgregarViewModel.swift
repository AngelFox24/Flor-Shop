import Foundation
import SwiftUI
import Kingfisher
import FlorShopDTOs
import _PhotosUI_SwiftUI

@Observable
final class AgregarViewModel {
    var agregarFields = AgregarFields()
    var selectedLocalImage: UIImage?
    var selectionImage: PhotosPickerItem? = nil {
        didSet{
            setImage(from: selectionImage)
        }
    }
    
    private let saveProductUseCase: SaveProductUseCase
    private let saveImageUseCase: SaveImageUseCase
    private let exportProductsUseCase: ExportProductsUseCase
    private let importProductsUseCase: ImportProductsUseCase
    private let getProductsUseCase: GetProductsUseCase
    //MARK: Init
    init(
        saveProductUseCase: SaveProductUseCase,
        saveImageUseCase: SaveImageUseCase,
        exportProductsUseCase: ExportProductsUseCase,
        importProductsUseCase: ImportProductsUseCase,
        getProductsUseCase: GetProductsUseCase
    ) {
        self.saveProductUseCase = saveProductUseCase
        self.saveImageUseCase = saveImageUseCase
        self.exportProductsUseCase = exportProductsUseCase
        self.importProductsUseCase = importProductsUseCase
        self.getProductsUseCase = getProductsUseCase
    }
    //MARK: Funtions
    func releaseResources() {
        self.selectedLocalImage = nil
        self.agregarFields = AgregarFields()
    }
    func saveSelectedImage() async throws {
        guard let selectedLocalImage else { return }
        let imageUrl = try await self.saveImageUseCase.execute(uiImage: selectedLocalImage)
        await MainActor.run {
            self.agregarFields.imageUrl = imageUrl.absoluteString
        }
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
                let result = try await KingfisherManager.shared.retrieveImage(
                    with: url,
                    options: [
                        .cacheMemoryOnly
                    ]
                )
                let optimizedImage = try self.saveImageUseCase.getOptimizedImage(uiImage: result.image)
                await MainActor.run {
                    print("Se le asigno la imagen")
                    self.agregarFields.imageUrl = urlPasted
                    self.agregarFields.idImage = nil
                    self.selectedLocalImage = optimizedImage
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
    func loadProduct(productCic: String) async throws {
        let product = try await self.getProductsUseCase.getProduct(productCic: productCic)
        try await editProduct(product: product)
    }
    func editProduct(product: Product) async throws {
        await MainActor.run {
            self.agregarFields.productCic = product.productCic
            self.agregarFields.productId = product.id
            self.agregarFields.active = product.active
            self.agregarFields.productName = product.name
            self.agregarFields.imageUrl = product.imageUrl ?? ""
            self.agregarFields.quantityStock = product.qty
            self.agregarFields.unitType = product.unitType
            self.agregarFields.unitCost = product.unitCost.cents
            self.agregarFields.unitPrice = product.unitPrice.cents
            self.agregarFields.scannedCode = product.barCode ?? ""
            print("[AgregarViewModel] barcode: \(product.barCode, default: "nil")")
            self.agregarFields.errorBD = ""
        }
        if let imageUrlString = product.imageUrl,
           let imageUrl = URL(string: imageUrlString) {
            print("[AgregarViewModel] Se contruyo la url: \(imageUrl.absoluteString)")
            let processor = DownsamplingImageProcessor(size: CGSize(width: 200, height: 200))
            let serializer = FormatIndicatedCacheSerializer.png
            var result: RetrieveImageResult?
            do {
                result = try await KingfisherManager.shared.retrieveImage(
                    with: imageUrl,
                    options: [
                        .onlyFromCache,
                        .processor(processor),
                        .cacheSerializer(serializer)
                    ]
                )
                print("[AgregarViewModel] Firstry trajo imagen desde cache")
            } catch {
                print("[AgregarViewModel] Firstry no trajo imagen, error: \(error)")
            }
            do {
                if result == nil {
                    result = try await KingfisherManager.shared.retrieveImage(
                        with: imageUrl,
                        options: [
                            .cacheMemoryOnly,
                            .processor(processor),
                            .cacheSerializer(serializer)
                        ]
                    )
                }
                print("[AgregarViewModel] Secondtry trajo imagen desde cache")
            } catch {
                print("[AgregarViewModel] Secondtry no trajo imagen, error: \(error)")
                throw error
            }
            print("[AgregarViewModel] Se obtuvo la imagen desde Kingfisher")
            guard let result else {
                throw KingfisherError.requestError(reason: .invalidURL(request: .init(url: imageUrl)))
            }
            let optimizedImage = try self.saveImageUseCase.getOptimizedImage(uiImage: result.image)
            print("[AgregarViewModel] Se optimizo la imagen")
            await MainActor.run {
                self.selectedLocalImage = optimizedImage
                print("[AgregarViewModel] Se coloca la imagen a la vista")
            }
        }
        print("Se verifica producto: \(self.agregarFields.productName)")
    }
    func createProduct() async throws -> Product? {
        if self.agregarFields.imageUrl == "" && self.selectedLocalImage != nil {
            try await self.saveSelectedImage()
        }
        guard let imageUrl = URL(string: self.agregarFields.imageUrl) else {
            print("[AgregarViewModel] Los valores no se pueden convertir correctamente, url: \(self.agregarFields.imageUrl)")
            return nil
        }
        if agregarFields.isErrorsEmpty() {
            return Product(
                id: self.agregarFields.productId ?? UUID(),
                productCic: self.agregarFields.productCic,
                active: self.agregarFields.active,
                barCode: self.agregarFields.scannedCode == "" ? nil : self.agregarFields.scannedCode,
                name: self.agregarFields.productName,
                qty: self.agregarFields.quantityStock,
                unitType: self.agregarFields.unitType,
                unitCost: Money(self.agregarFields.unitCost),
                unitPrice: Money(self.agregarFields.unitPrice),
                expirationDate: self.agregarFields.expirationDate,
                imageUrl: imageUrl.absoluteString
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
                let optimizedImage = try self.saveImageUseCase.getOptimizedImage(uiImage: uiImage)
                await MainActor.run {
                    print("Se le asigno la imagen")
                    self.agregarFields.imageUrl = ""
                    self.selectedLocalImage = optimizedImage
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
}
//MARK: Fields
struct AgregarFields {
    var isShowingPicker = false
    var isShowingScanner = false
    var productId: UUID?
    var productCic: String?
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
    var quantityStock: Int = 0
    var quantityEdited: Bool = false
    var quantityError: String {
        if quantityEdited {
            if quantityStock < 0 && quantityEdited {
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
    var unitType: UnitType = .unit
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
