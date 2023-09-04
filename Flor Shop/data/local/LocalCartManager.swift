//
//  LocalCarManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol CartManager {
    func getCart() -> Car?
    func getCartEmployee() -> Employee?
    func deleteProduct(product: Product)
    func addProductToCart(productIn: Product) -> Bool
    func emptyCart()
    func updateCartTotal()
    func increaceProductAmount(product: Product)
    func decreceProductAmount(product: Product)
    func getListProductInCart () -> [CartDetail]
    func createCart()
    func setDefaultEmployee(employee: Employee)
    func getDefaultEmployee() -> Employee?
}

class LocalCartManager: CartManager {
    let mainContext: NSManagedObjectContext
    var mainEmployeeEntity: Tb_Employee?
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            self.mainContext.rollback()
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    func createCart() {
        print("Se llamo a createCart")
        guard let employeeEntity = self.mainEmployeeEntity else {
            print("No se encontro empleado default para crear carrito")
            return
        }
        print("Empleado existe por defecto en CartManager \(employeeEntity.toEmployee().name)")
        if getCartEntity() == nil {
            let newCart: Tb_Cart = Tb_Cart(context: self.mainContext)
            newCart.idCart = UUID()
            newCart.total = 0.0
            newCart.toEmployee = employeeEntity
            // Redundante?
            self.mainEmployeeEntity?.toCart = newCart
            saveData()
        } else {
            print("Existe carrito ya creado para este empleado \(employeeEntity.toEmployee().name)")
        }
    }
    func getCart() -> Car? {
        print("Se llamo a getCart en LocalCartManager")
        return getCartEntity()?.mapToCar()
    }
    func getCartEmployee() -> Employee? {
        return mainEmployeeEntity?.toEmployee()
    }
    private func getCartEntity() -> Tb_Cart? {
        return self.mainEmployeeEntity?.toCart
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
        if let cart = getCartEntity() {
            cart.toCartDetail = nil
            cart.total = 0
            saveData()
        }
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
    func setDefaultEmployee(employee: Employee) {
        guard let employeeEntity = employee.toEmployeeEntity(context: self.mainContext) else {
            print("No se pudo asingar employee default")
            return
        }
        self.mainEmployeeEntity = employeeEntity
    }
    func getDefaultEmployee() -> Employee? {
        return self.mainEmployeeEntity?.toEmployee()
    }
}
