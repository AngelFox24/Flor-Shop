//
//  LocalCarManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol LocalCartManager {
    func getCart() throws -> Car?
    func deleteCartDetail(cartDetail: CartDetail)
    func addProductToCart(productIn: Product) throws
    func changeProductAmountInCartDetail(productId: UUID, amount: Int) throws
    func emptyCart()
    func updateCartTotal()
}

class LocalCartManagerImpl: LocalCartManager {
    let mainContext: NSManagedObjectContext
    let sessionConfig: SessionConfig
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            self.mainContext.rollback()
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    private func createCart() {
        let newCart: Tb_Cart = Tb_Cart(context: self.mainContext)
        newCart.idCart = UUID()
        newCart.total = 0
        newCart.toEmployee?.idEmployee = self.sessionConfig.employeeId
        // Redundante?
        self.mainEmployeeEntity?.toCart = newCart
        saveData()
    }
    func getCart() throws -> Car? {
        let employeeEntity = try self.sessionConfig.getEmployeeEntity(context: self.mainContext)
        return employeeEntity.toCart?.toCar()
    }
    func deleteCartDetail(cartDetail: CartDetail) {
        guard let cartDetailEntity = cartDetail.toCartDetailEntity(context: self.mainContext) else {
            print("Detalle de producto no existe en carrito")
            return
        }
        self.mainContext.delete(cartDetailEntity)
        updateCartTotal()
        saveData()
    }
    func addProductToCart(productIn: Product) throws {
        var success: Bool = false
        //Verificamos si el empleado por defecto existe
        guard let employeeEntity = self.sessionConfig.getEmployeeEntity(context: self.mainContext) else {
            print("Empleado por defecto no existe")
            return false
        }
        //Verificamos si tiene un carrito asignado
        guard let cartEntity = employeeEntity.toCart else {
            print("Empleado por defecto no tiene carrito")
            return false
        }
        // Buscamos si existe este producto en el carrito
        if let cartDetailEntity = getCartDetail(productId: productIn.id) {
            try changeProductAmountInCartDetail(productId: productIn, amount: Int(cartDetailEntity.quantityAdded) + 1)
            success = true
        } else {
            // Validamos si tiene sificiente Stock
            if productIn.qty >= 1 {
                let newCarDetail = Tb_CartDetail(context: self.mainContext)
                newCarDetail.idCartDetail = UUID() // Genera un nuevo UUID para el detalle del carrito
                newCarDetail.quantityAdded = 1
                newCarDetail.subtotal = Int64(productIn.unitPrice.cents) * newCarDetail.quantityAdded
                newCarDetail.toProduct?.idProduct = productIn.id
                newCarDetail.toCart = cartEntity
                success = true
            } else {
                print("No hay stock suficiente: \(productEntity.quantityStock)")
                success = false
            }
        }
        if success {
            updateCartTotal()
            saveData()
        } else {
            rollback()
        }
    }
    func emptyCart() {
        guard let employeeEntity = try self.sessionConfig.getEmployeeEntity(context: self.mainContext) else {
            print("El empleado por defecto no esta configurado")
            throw LocalStorageError.notFound("El empleado por defecto no esta configurado")
        }
        if let cartEntity = employeeEntity.toCart {
            cartEntity.toCartDetail = nil
            cartEntity.total = 0
            saveData()
        }
    }
    func changeProductAmountInCartDetail(productId: UUID, amount: Int) throws {
        //Verificamos si existe este detalle
        guard let cartDetailEntity = getCartDetail(productId: productId) else {
            print("Detalle de producto no existe en carrito")
            throw LocalStorageError.notFound("Detalle de producto no existe en carrito")
        }
        guard let productEntity = cartDetailEntity.toProduct else {
            print("Este detalle de carrito no tiene producto")
            throw LocalStorageError.notFound("Este detalle de carrito no tiene producto")
        }
        if productEntity.quantityStock >= Int64(amount) {
            cartDetailEntity.quantityAdded = Int64(amount)
            cartDetailEntity.subtotal = cartDetailEntity.quantityAdded * productEntity.unitPrice
        } else {
            print("Producto no tiene stock suficiente")
            throw LocalStorageError.notFound("Producto no tiene stock suficiente")
        }
        updateCartTotal()
        saveData()
    }
    private func getCartDetail(productId: UUID) -> Tb_CartDetail? {
        let request: NSFetchRequest<Tb_CartDetail> = Tb_CartDetail.fetchRequest()
        let predicate = NSPredicate(format: "toProduct.idProduct == %@", productId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try self.mainContext.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func updateCartTotal() {
        guard let employeeEntity = try self.sessionConfig.getEmployeeEntity(context: self.mainContext) else {
            print("El empleado por defecto no esta configurado")
            throw LocalStorageError.notFound("El empleado por defecto no esta configurado")
        }
        guard let cartEntity = employeeEntity.toCart else {
            print("El empleado por defecto no tiene carrito")
            throw LocalStorageError.notFound("El empleado por defecto no tiene carrito")
        }
        //Verificamos si existe detalle del carrito
        guard let cartDetailEntityList = cartEntity.toCartDetail?.compactMap({ $0 as? Tb_CartDetail }) else {
            print("El carrito no tiene detalle")
            cartEntity.total = 0
            saveData()
            return
        }
        cartEntity.total = cartDetailEntityList.reduce(0) {$0 + $1.subtotal}
        saveData()
    }
}
