import Foundation
import CoreData
import FlorShopDTOs

protocol LocalProductManager {
    func save(product: Product) throws
    func sync(backgroundContext: NSManagedObjectContext, productsDTOs: [ProductClientDTO]) throws
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product]
    func getLastToken(context: NSManagedObjectContext) -> Int64
    func getLastToken() -> Int64
    func updateProducts(products: [Product]) -> [Product]
    func getProduct(productCic: String) throws -> Product
}

class LocalProductManagerImpl: LocalProductManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let className = "[LocalProductManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastToken() -> Int64 {
        return self.getLastToken(context: self.mainContext)
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.companyCic == %@ AND syncToken != nil", self.sessionConfig.companyCic)
        let sortDescriptor = NSSortDescriptor(key: "syncToken", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let syncToken = try self.mainContext.fetch(request).compactMap{$0.syncToken}.first
            return syncToken ?? 0
        } catch let error {
            print("Error fetching. \(error)")
            return 0
        }
    }
    func updateProducts(products: [Product]) -> [Product] {
        let ids = products.compactMap(\.productCic)
        let request: NSFetchRequest<Tb_ProductSubsidiary> = Tb_ProductSubsidiary.fetchRequest()
        request.predicate = NSPredicate(format: "productCic IN %@", ids)
        do {
            var productsEntities = try self.mainContext.fetch(request).compactMap{ try? $0.toProductModel() }
            print("\(className) products raw to update: \(productsEntities)")
            productsEntities = productsEntities.filter { productRaw in
                !products.contains(where: { productIn in
                    print("\(className) productIn: \(productIn) \n productRaw: \(productRaw)")
                    if productIn.isEquals(to: productRaw) {
                        print("\(className) son iguales")
                        return true
                    } else {
                        print("\(className) no son iguales")
                        return false
                    }
                })
            }
            print("\(className) products filtered to update: \(productsEntities)")
            return productsEntities
        } catch {
            print("Error fetching. \(error)")
            return []
        }
    }
    func getProduct(productCic: String) throws -> Product {
        guard let productEntity = try self.sessionConfig.getProductSubsidiaryEntityByCic(
            context: self.mainContext,
            productCic: productCic
        )
        else {
            throw LocalStorageError.entityNotFound("No se encontro producto")
        }
        return try productEntity.toProductModel()
    }
    //TODO: Refactor this
    func getProducts(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int, pageSize: Int) -> [Product] {
        let request: NSFetchRequest<Tb_ProductSubsidiary> = Tb_ProductSubsidiary.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        var predicate1 = NSPredicate(format: "toSubsidiary.subsidiaryCic == %@", self.sessionConfig.subsidiaryCic)
        if seachText != "" {
            predicate1 = NSPredicate(format: "toProduct.productName CONTAINS[c] %@ AND toSubsidiary.subsidiaryCic == %@", seachText, self.sessionConfig.subsidiaryCic)
        }
        let predicate2 = getFilterAtribute(filter: filterAttribute)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        
        request.predicate = compoundPredicate
        let sortDescriptor = getOrderFilter(order: primaryOrder)
        request.sortDescriptors = [sortDescriptor]
        do {
            return try self.mainContext.fetch(request).compactMap{ try? $0.toProductModel() }
        } catch {
            print("Error fetching. \(error)")
            return []
        }
    }
    func save(product: Product) throws {
        guard let comnpanyEntity = try self.sessionConfig.getCompanyEntityByCic(
            context: self.mainContext,
            companyCic: self.sessionConfig.companyCic
        ) else {
            print("No se pudo obtener la compañia")
            rollback()
            throw LocalStorageError.entityNotFound("No se pudo obtener la compañia")
        }
        guard product.name != "" else {
            print("El nombre del producto no puede ser vacio")
            rollback()
            throw LocalStorageError.invalidInput("El nombre del producto no puede ser vacio")
        }
        if let productCic = product.productCic,
           let productSubsidiaryEntity = try self.sessionConfig.getProductSubsidiaryEntityByCic(context: self.mainContext, productCic: productCic) {
            guard let productEntity = productSubsidiaryEntity.toProduct else {
                rollback(context: self.mainContext)
                let cusError: String = "\(className): El product no existe para esta sucursal."
                throw LocalStorageError.entityNotFound(cusError)
            }
            if productEntity.productName != product.name {
                guard !productNameExist(name: product.name, company: comnpanyEntity) else {
                    print("El nombre del producto ya existe en otro producto")
                    rollback()
                    throw BusinessLogicError.duplicateProductName("El nombre del producto ya existe en otro producto")
                }
                productEntity.productName = product.name
            }
            if productEntity.barCode != product.barCode {
                guard !productBarCodeExist(barcode: product.barCode ?? "", company: comnpanyEntity) else {
                    print("El codigo de barras ya existe en otro producto")
                    rollback()
                    throw BusinessLogicError.duplicateBarCode("El codigo de barras ya existe en otro producto")
                }
                productEntity.barCode = product.barCode
            }
            productEntity.barCode = product.barCode
            productEntity.productName = product.name
            productEntity.unitType = product.unitType.rawValue
            productEntity.imageUrl = product.imageUrl
            productEntity.updatedAt = Date()
            productSubsidiaryEntity.active = product.active
            productSubsidiaryEntity.quantityStock = Int64(product.qty)
            productSubsidiaryEntity.unitCost = Int64(product.unitCost.cents)
            productSubsidiaryEntity.expirationDate = product.expirationDate
            productSubsidiaryEntity.unitPrice = Int64(product.unitPrice.cents)
            productSubsidiaryEntity.updatedAt = Date()
            try saveData()
        } else {
            guard !productNameExist(name: product.name, company: comnpanyEntity) else {
                print("El nombre del producto ya existe en otro producto")
                rollback()
                throw BusinessLogicError.duplicateProductName("El nombre del producto ya existe en otro producto")
            }
            guard !productBarCodeExist(barcode: product.barCode ?? "", company: comnpanyEntity) else {
                print("El codigo de barras ya existe en otro producto")
                rollback()
                throw BusinessLogicError.duplicateBarCode("El codigo de barras ya existe en otro producto")
            }
            guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
                context: self.mainContext,
                subsidiaryCic: self.sessionConfig.subsidiaryCic
            ) else {
                rollback(context: self.mainContext)
                let cusError: String = "\(className): La subsidiaria no existe en la BD local"
                throw LocalStorageError.syncFailed(cusError)
            }
            let newProductEntity = Tb_Product(context: mainContext)
            newProductEntity.productCic = UUID().uuidString
            newProductEntity.productName = product.name
            newProductEntity.barCode = product.barCode
            newProductEntity.imageUrl = product.imageUrl
            newProductEntity.createdAt = Date()
            newProductEntity.updatedAt = Date()
            newProductEntity.toCompany = comnpanyEntity
            let newProductSubsidiaryEntity = Tb_ProductSubsidiary(context: mainContext)
            newProductSubsidiaryEntity.active = product.active
            newProductSubsidiaryEntity.quantityStock = Int64(product.qty)
            newProductSubsidiaryEntity.unitCost = Int64(product.unitCost.cents)
            newProductSubsidiaryEntity.unitPrice = Int64(product.unitPrice.cents)
            newProductSubsidiaryEntity.expirationDate = product.expirationDate
            newProductSubsidiaryEntity.toProduct = newProductEntity
            newProductSubsidiaryEntity.toSubsidiary = subsidiaryEntity
            try saveData()
        }
    }
    func sync(backgroundContext: NSManagedObjectContext, productsDTOs: [ProductClientDTO]) throws {
        for productDTO in productsDTOs {
            guard self.sessionConfig.companyCic == productDTO.companyCic else {
                print("Error en la sincronizacion, la compañia no es la misma")
                rollback(context: backgroundContext)
                throw LocalStorageError.syncFailed("Error en la sincronizacion, la subsidiaria no es la misma")
            }
            guard let companyEntity = try self.sessionConfig.getCompanyEntityByCic(
                context: backgroundContext,
                companyCic: productDTO.companyCic
            ) else {
                print("No se pudo obtener la subsidiaria")
                rollback(context: backgroundContext)
                throw LocalStorageError.entityNotFound("No se pudo obtener la subsidiaria")
            }
            if let productEntity = try self.sessionConfig.getProductEntityByCic(context: backgroundContext, productCic: productDTO.productCic) {
                guard !productDTO.isEquals(to: productEntity) else {
                    print("\(className) No se actualizo el producto porque es el mismo")
                    continue
                }
                productEntity.productName = productDTO.productName
                productEntity.barCode = productDTO.barCode
                productEntity.syncToken = productDTO.syncToken
                productEntity.createdAt = productDTO.createdAt
                productEntity.updatedAt = productDTO.updatedAt
                productEntity.imageUrl = productDTO.imageUrl
                try saveData(context: backgroundContext)
                print("\(className) Se actualizo el producto")
            } else {
                let newProductEntity = Tb_Product(context: backgroundContext)
                newProductEntity.productCic = productDTO.productCic
                newProductEntity.productName = productDTO.productName
                newProductEntity.barCode = productDTO.barCode
                newProductEntity.syncToken = productDTO.syncToken
                newProductEntity.createdAt = productDTO.createdAt
                newProductEntity.updatedAt = productDTO.updatedAt
                newProductEntity.imageUrl = productDTO.imageUrl
                newProductEntity.toCompany = companyEntity
                try saveData(context: backgroundContext)
                print("\(className) Se creo el producto")
            }
        }
    }
    //MARK: Private Functions
    private func productNameExist(name: String, company: Tb_Company) -> Bool {
        guard name != "" else {
            print("Producto existe vacio aunque no exista xd")
            return true
        }
        let filterAtt = NSPredicate(format: "name == %@ AND toCompany == %@", name, company)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        request.fetchLimit = 1
        do {
            let total = try self.mainContext.fetch(request).count
            return total == 0 ? false : true
        } catch let error {
            print("Error fetching. \(error)")
            return false
        }
    }
    private func productBarCodeExist(barcode: String, company: Tb_Company) -> Bool {
        guard barcode != "" else {
            print("Producto barcode vacio aunque no exista xd")
            return false
        }
        let filterAtt = NSPredicate(format: "barCode == %@ AND toCompany == %@", barcode, company)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        request.fetchLimit = 1
        do {
            let total = try self.mainContext.fetch(request).count
            return total == 0 ? false : true
        } catch let error {
            print("Error fetching. \(error)")
            return false
        }
    }
    private func saveData() throws {
        do {
            try self.mainContext.save()
        } catch {
            rollback()
            let cusError: String = "\(className): \(error.localizedDescription)"
            throw LocalStorageError.saveFailed(cusError)
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
    private func saveData(context: NSManagedObjectContext) throws {
        do {
            try context.save()
        } catch {
            rollback(context: context)
            let cusError: String = "\(className) - BackgroundContext: \(error.localizedDescription)"
            throw LocalStorageError.saveFailed(cusError)
        }
    }
    private func rollback(context: NSManagedObjectContext) {
        context.rollback()
    }
    private func getOrderFilter(order: PrimaryOrder) -> NSSortDescriptor {
        var sortDescriptor = NSSortDescriptor(key: "toProduct.productName", ascending: true)
        switch order {
        case .nameAsc:
            sortDescriptor = NSSortDescriptor(key: "toProduct.productName", ascending: true)
        case .nameDesc:
            sortDescriptor = NSSortDescriptor(key: "toProduct.productName", ascending: false)
        case .priceAsc:
            sortDescriptor = NSSortDescriptor(key: "unitPrice", ascending: true)
        case .priceDesc:
            sortDescriptor = NSSortDescriptor(key: "unitPrice", ascending: false)
        case .quantityAsc:
            sortDescriptor = NSSortDescriptor(key: "quantityStock", ascending: true)
        case .quantityDesc:
            sortDescriptor = NSSortDescriptor(key: "quantityStock", ascending: false)
        }
        return sortDescriptor
    }
    private func getFilterAtribute(filter: ProductsFilterAttributes) -> NSPredicate {
        var filterAtt = NSPredicate(format: "quantityStock != 0")
        switch filter {
        case .allProducts:
            filterAtt = NSPredicate(format: "quantityStock != 0 AND active == true")
        case .outOfStock:
            filterAtt = NSPredicate(format: "quantityStock == 0")
        case .productWithdrawn:
            filterAtt = NSPredicate(format: "active == false")
        }
        return filterAtt
    }
}
