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
    func addProductToCart(productIn: Product)
    func emptyCart()
    func updateCartTotal()
    func increaceProductAmount(product: Product)
    func decreceProductAmount(product: Product)
    func getListProductInCart () -> [CartDetail]
}

class LocalCarManager: CarManager {
    let cartContainer: NSPersistentContainer
    init(containerBDFlor: NSPersistentContainer) {
        self.cartContainer = containerBDFlor
    }
    func saveData() {
        do {
            try self.cartContainer.viewContext.save()
        } catch {
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    func getCar() -> Car {
        var cart: Tb_Carrito?
        let request: NSFetchRequest<Tb_Carrito> = Tb_Carrito.fetchRequest()
        do {
            cart = try self.cartContainer.viewContext.fetch(request).first
            if cart == nil {
                cart = Tb_Carrito(context: self.cartContainer.viewContext)
                cart!.idCarrito = UUID()
                cart!.fechaCarrito = Date()
                cart!.totalCarrito = 0.0
                saveData()
            }
        } catch let error {
            print("Error al recuperar el carrito de productos \(error)")
        }
        return cart!.mapToCar()
    }
    private func getCartEntity() -> Tb_Carrito? {
        var cart: Tb_Carrito?
        let request: NSFetchRequest<Tb_Carrito> = Tb_Carrito.fetchRequest()
        do {
            cart = try self.cartContainer.viewContext.fetch(request).first
        } catch let error {
            print("Error al recuperar el carrito de productos \(error)")
        }
        return cart
    }
    func deleteProduct(product: Product) {
        guard let cart = getCartEntity(), let cartDetail = cart.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        let detailToDelete = cartDetail.filter { $0.detalleCarrito_to_producto?.idProducto == product.id }
        if let detail = detailToDelete.first {
            cart.removeFromCarrito_to_detalleCarrito(detail)
        }
        updateCartTotal()
        saveData()
    }
    func addProductToCart(productIn: Product) {
        let context = self.cartContainer.viewContext
        guard let cart = getCartEntity(), let product = productIn.toProductEntity(context: context), let cartDetail = cart.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        // Buscamos si existe este producto en el carrito
        let matchingDetails = cartDetail.filter { $0.detalleCarrito_to_producto?.idProducto == product.idProducto }
        if matchingDetails.first != nil {
            increaceProductAmount(product: productIn)
        } else {
            // Crear el objeto detalleCarrito y establecer sus propiedades
            let newCarDetail = Tb_DetalleCarrito(context: context)
            newCarDetail.idDetalleCarrito = UUID() // Genera un nuevo UUID para el detalle del carrito
            // detalleCarrito.detalleCarrito_to_carrito = carrito // Asigna el ID del carrito existente
            newCarDetail.cantidad = 1
            newCarDetail.subtotal = product.precioUnitario * newCarDetail.cantidad
            // Agregar el objeto producto al detalle carrito
            newCarDetail.detalleCarrito_to_producto = product
            // Agregar el objeto detalleCarrito al carrito
            newCarDetail.detalleCarrito_to_carrito = cart
        }
        updateCartTotal()
        saveData()
    }
    func emptyCart() {
        guard let cart = getCartEntity() else {
            return
        }
        cart.carrito_to_detalleCarrito = nil
        updateCartTotal()
        saveData()
    }
    func updateCartTotal() {
        guard let cart = getCartEntity(), let cartDetail = cart.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        var total: Double = 0.0
        for product in cartDetail {
            total += product.cantidad * (product.detalleCarrito_to_producto?.precioUnitario ?? 0.0)
        }
        cart.totalCarrito = total
    }
    func increaceProductAmount (product: Product) {
        guard let cart = getCartEntity(), let cartDetail = cart.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        let detailToAdd = cartDetail.filter { $0.detalleCarrito_to_producto?.idProducto == product.id }
        if let detail = detailToAdd.first {
            if let cantidadStock = detail.detalleCarrito_to_producto?.cantidadStock {
                if cantidadStock > detail.cantidad {
                    detail.cantidad += 1.0
                }
            }
        }
        updateCartTotal()
        saveData()
    }
    func decreceProductAmount(product: Product) {
        guard let cart = getCartEntity(), let cartDetail = cart.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        let detailToAdd = cartDetail.filter { $0.detalleCarrito_to_producto?.idProducto == product.id }
        if let detail = detailToAdd.first {
            if detail.cantidad > 1 {
                detail.cantidad -= 1.0
            }
        }
        updateCartTotal()
        saveData()
    }
    func getListProductInCart () -> [CartDetail] {
        let cartDetails: [Tb_DetalleCarrito] = []
        guard let cart = getCartEntity(), let cartDetail = cart.carrito_to_detalleCarrito?.compactMap({ $0 as? Tb_DetalleCarrito }) else {
            return cartDetails.mapToListCartDetail()
        }
        return cartDetail.mapToListCartDetail()
    }
}
