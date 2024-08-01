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
    func deleteCartDetail(cartDetail: CartDetail) throws
    func addProductToCart(productIn: Product) throws
    func changeProductAmountInCartDetail(productId: UUID, amount: Int) throws
    func emptyCart() throws
    func updateCartTotal() throws
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
    func getCart() throws -> Car? {
        return try getCartEntity()?.toCar()
    }
    func deleteCartDetail(cartDetail: CartDetail) throws {
        guard let cartDetailEntity = self.sessionConfig.getCartDetailEntityById(context: self.mainContext, cartDetailId: cartDetail.id) else {
            print("Detalle de producto no existe en carrito")
            return
        }
        self.mainContext.delete(cartDetailEntity)
        try updateCartTotal()
        saveData()
    }
    func addProductToCart(productIn: Product) throws {
        try ensureCartExist()
        var success: Bool = false
        guard let cartEntity = try getCartEntity() else {
            print("Empleado por defecto no tiene carrito")
            throw LocalStorageError.notFound("Empleado por defecto no tiene carrito")
        }
        if let cartDetailEntity = try getCartDetail(productId: productIn.id) {
            try changeProductAmountInCartDetail(productId: productIn.id, amount: Int(cartDetailEntity.quantityAdded) + 1)
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
                print("No hay stock suficiente: \(productIn.qty)")
                success = false
            }
        }
        if success {
            try updateCartTotal()
            saveData()
        } else {
            rollback()
        }
    }
    func changeProductAmountInCartDetail(productId: UUID, amount: Int) throws {
        try ensureCartExist()
        guard let cartDetailEntity = try getCartDetail(productId: productId) else {
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
        try updateCartTotal()
        saveData()
    }
    func emptyCart() throws {
        try ensureCartExist()
        guard let employeeEntity = self.sessionConfig.getEmployeeEntityById(context: self.mainContext, employeeId: self.sessionConfig.employeeId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
        }
        guard let cartEntity = employeeEntity.toCart else {
            throw LocalStorageError.notFound("El empleado por defecto no tiene carrito asignado")
        }
        cartEntity.toCartDetail = nil
        cartEntity.total = 0
        saveData()
    }
    func updateCartTotal() throws {
        try ensureCartExist()
        guard let employeeEntity = self.sessionConfig.getEmployeeEntityById(context: self.mainContext, employeeId: self.sessionConfig.employeeId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
        }
        guard let cartEntity = employeeEntity.toCart else {
            print("El empleado por defecto no tiene carrito")
            throw LocalStorageError.notFound("El empleado por defecto no tiene carrito")
        }
        guard let cartDetailEntityList = cartEntity.toCartDetail?.compactMap({ $0 as? Tb_CartDetail }) else {
            print("El carrito no tiene detalle")
            cartEntity.total = 0
            saveData()
            return
        }
        cartEntity.total = cartDetailEntityList.reduce(0) {$0 + $1.subtotal}
        saveData()
    }
    //MARK: Private Functions
    private func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            rollback()
            print("Error al guardar en ProductRepositoryImpl \(error)")
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
    private func createCart() {
        let newCart: Tb_Cart = Tb_Cart(context: self.mainContext)
        newCart.idCart = UUID()
        newCart.total = 0
        newCart.toEmployee?.idEmployee = self.sessionConfig.employeeId
        saveData()
    }
    func getCartEntity() throws -> Tb_Cart? {
        try ensureCartExist()
        guard let employeeEntity = self.sessionConfig.getEmployeeEntityById(context: self.mainContext, employeeId: self.sessionConfig.employeeId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
        }
        return employeeEntity.toCart
    }
    private func cartExist() throws -> Bool {
        guard let employeeEntity = self.sessionConfig.getEmployeeEntityById(context: self.mainContext, employeeId: self.sessionConfig.employeeId) else {
            throw LocalStorageError.notFound("No se encontro la subisidiaria")
        }
        guard let _ = employeeEntity.toCart else {
            return false
        }
        return true
    }
    private func ensureCartExist() throws {
        if try !cartExist() {
            createCart()
        }
    }
    private func getCartDetail(productId: UUID) throws -> Tb_CartDetail? {
        try ensureCartExist()
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
}
