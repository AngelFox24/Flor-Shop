//
//  LocalCarManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol CarManager {
    func getCar() -> Car
    func deleteProduct(product: Product)
    func addProductToCart(productIn: Product) -> Bool
    func emptyCart()
    func updateCartTotal()
    func increaceProductAmount(product: Product)
    func decreceProductAmount(product: Product)
    func getListProductInCart () -> [CartDetail]
}

class LocalCarManager: CarManager {
    let mainContext: NSManagedObjectContext
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    func getCar() -> Car {
        var cart: Tb_Cart?
        let request: NSFetchRequest<Tb_Cart> = Tb_Cart.fetchRequest()
        do {
            cart = try self.mainContext.fetch(request).first
            if cart == nil {
                cart = Tb_Cart(context: self.mainContext)
                cart!.idCart = UUID()
                cart!.total = 0.0
                saveData()
            }
        } catch let error {
            print("Error al recuperar el carrito de productos \(error)")
        }
        return cart!.mapToCar()
    }
    private func getCartEntity() -> Tb_Cart? {
        var cart: Tb_Cart?
        let request: NSFetchRequest<Tb_Cart> = Tb_Cart.fetchRequest()
        do {
            cart = try self.mainContext.fetch(request).first
        } catch let error {
            print("Error al recuperar el carrito de productos \(error)")
        }
        return cart
    }
    func deleteProduct(product: Product) {
        guard let cart = getCartEntity(), let cartDetail = cart.toCartDetail as? Set<Tb_CartDetail> else {
            return
        }
        let detailToDelete = cartDetail.filter { $0.toProduct?.idProduct == product.id }
        if let detail = detailToDelete.first {
            cart.removeFromToCartDetail(detail)
        }
        updateCartTotal()
        saveData()
    }
    func addProductToCart(productIn: Product) -> Bool {
        var success: Bool = false
        guard let cart = getCartEntity(), let product = productIn.toProductEntity(context: mainContext), let cartDetail = cart.toCartDetail as? Set<Tb_CartDetail> else {
            return success
        }
        // Buscamos si existe este producto en el carrito
        let matchingDetails = cartDetail.filter { $0.toProduct?.idProduct == product.idProduct }
        if matchingDetails.first != nil {
            increaceProductAmount(product: productIn)
            success = true
        } else {
            // Validamos si tiene sificiente Stock
            if product.quantityStock >= 1 {
                // Crear el objeto detalleCarrito y establecer sus propiedades
                let newCarDetail = Tb_CartDetail(context: mainContext)
                newCarDetail.idCartDetail = UUID() // Genera un nuevo UUID para el detalle del carrito
                // detalleCarrito.detalleCarrito_to_carrito = carrito // Asigna el ID del carrito existente
                newCarDetail.quantityAdded = 1
                newCarDetail.subtotal = product.unitPrice * Double(newCarDetail.quantityAdded)
                // Agregar el objeto producto al detalle carrito
                newCarDetail.toProduct = product
                // Agregar el objeto detalleCarrito al carrito
                newCarDetail.toCart = cart
                success = true
            } else {
                print("No hay stock suficiente: \(product.quantityStock)")
                success = false
            }
        }
        if success {
            updateCartTotal()
            saveData()
        }
        return success
    }
    func emptyCart() {
        guard let cart = getCartEntity() else {
            return
        }
        cart.toCartDetail = nil
        updateCartTotal()
        saveData()
    }
    func updateCartTotal() {
        guard let cart = getCartEntity(), let cartDetail = cart.toCartDetail as? Set<Tb_CartDetail> else {
            return
        }
        var total: Double = 0.0
        for product in cartDetail {
            total += Double(product.quantityAdded) * (product.toProduct?.unitPrice ?? 0.0)
        }
        cart.total = total
    }
    func increaceProductAmount (product: Product) {
        guard let cart = getCartEntity(), let cartDetail = cart.toCartDetail as? Set<Tb_CartDetail> else {
            return
        }
        let detailToAdd = cartDetail.filter { $0.toProduct?.idProduct == product.id }
        if let detail = detailToAdd.first {
            if let cantidadStock = detail.toProduct?.quantityStock {
                if cantidadStock > detail.quantityAdded {
                    detail.quantityAdded += 1
                }
            }
        }
        updateCartTotal()
        saveData()
    }
    func decreceProductAmount(product: Product) {
        guard let cart = getCartEntity(), let cartDetail = cart.toCartDetail as? Set<Tb_CartDetail> else {
            return
        }
        let detailToAdd = cartDetail.filter { $0.toProduct?.idProduct == product.id }
        if let detail = detailToAdd.first {
            if detail.quantityAdded > 1 {
                detail.quantityAdded -= 1
            }
        }
        updateCartTotal()
        saveData()
    }
    func getListProductInCart () -> [CartDetail] {
        let cartDetails: [Tb_CartDetail] = []
        guard let cart = getCartEntity(), let cartDetail = cart.toCartDetail?.compactMap({ $0 as? Tb_CartDetail }) else {
            return cartDetails.mapToListCartDetail()
        }
        return cartDetail.mapToListCartDetail()
    }
}
