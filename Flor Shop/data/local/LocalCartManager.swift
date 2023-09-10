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
    func deleteCartDetail(cartDetail: CartDetail)
    func addProductToCart(productIn: Product) -> Bool
    func emptyCart()
    func updateCartTotal()
    func increaceProductAmount(cartDetail: CartDetail)
    func decreceProductAmount(cartDetail: CartDetail)
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
    func rollback() {
        self.mainContext.rollback()
    }
    func createCart() {
        print("Se llamo a createCart")
        guard let employeeEntity = self.mainEmployeeEntity else {
            print("No se encontro empleado default para crear carrito")
            return
        }
        print("Empleado existe por defecto en CartManager \(employeeEntity.toEmployee().name)")
        if let _ = self.mainEmployeeEntity?.toCart {
            print("Existe carrito ya creado para este empleado \(employeeEntity.toEmployee().name)")
        } else {
            let newCart: Tb_Cart = Tb_Cart(context: self.mainContext)
            newCart.idCart = UUID()
            newCart.total = 0.0
            newCart.toEmployee = employeeEntity
            // Redundante?
            self.mainEmployeeEntity?.toCart = newCart
            saveData()
        }
    }
    func getCart() -> Car? {
        print("Se llamo a getCart en LocalCartManager")
        return self.mainEmployeeEntity?.toCart?.toCar()
    }
    func deleteCartDetail(cartDetail: CartDetail) {
        //Verficamos si existe este detalle
        guard let cartDetailEntity = cartDetail.toCartDetailEntity(context: self.mainContext) else {
            print("Detalle de producto no existe en carrito")
            return
        }
        //Verificamos carrito del empleado
        guard let employeeCartEntity = self.mainEmployeeEntity?.toCart else {
            print("Empleado por defecto no tiene carrito")
            return
        }
        employeeCartEntity.removeFromToCartDetail(cartDetailEntity)
        updateCartTotal()
        saveData()
    }
    func addProductToCart(productIn: Product) -> Bool {
        var success: Bool = false
        //Verificamos si el empleado por defecto existe
        guard let employeeEntity = self.mainEmployeeEntity else {
            print("Empleado por defecto no existe")
            return false
        }
        //Verificamos si tiene un carrito asignado
        guard let employeeCartEntity = employeeEntity.toCart else {
            print("Empleado por defecto no tiene carrito")
            return false
        }
        //Verificamos si el producto existe en la BD
        guard let productEntity = productIn.toProductEntity(context: self.mainContext) else {
            print("Producto ingresado no existe en la BD")
            return false
        }
        // Buscamos si existe este producto en el carrito
        if let cartDetailEntity = existProductInCart(productEntity: productEntity) {
            increaceProductAmount(cartDetail: cartDetailEntity.toCarDetail())
            success = true
        } else {
            // Validamos si tiene sificiente Stock
            if productEntity.quantityStock >= 1 {
                // Crear el objeto detalleCarrito y establecer sus propiedades
                let newCarDetail = Tb_CartDetail(context: self.mainContext)
                newCarDetail.idCartDetail = UUID() // Genera un nuevo UUID para el detalle del carrito
                // detalleCarrito.detalleCarrito_to_carrito = carrito // Asigna el ID del carrito existente
                newCarDetail.quantityAdded = 1
                newCarDetail.subtotal = productEntity.unitPrice * Double(newCarDetail.quantityAdded)
                // Agregar el objeto producto al detalle carrito
                newCarDetail.toProduct = productEntity
                // Agregar el objeto detalleCarrito al carrito
                newCarDetail.toCart = employeeCartEntity
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
        return success
    }
    private func existProductInCart(productEntity: Tb_Product) -> Tb_CartDetail? {
        //Verificamos si el empleado por defecto existe
        guard let employeeEntity = self.mainEmployeeEntity else {
            print("Empleado por defecto no existe")
            return nil
        }
        //Verificamos si tiene un carrito asignado
        guard let employeeCartEntity = employeeEntity.toCart else {
            print("Empleado por defecto no tiene carrito")
            return nil
        }
        let filterAtt = NSPredicate(format: "toProduct == %@ AND toCart == %@", productEntity, employeeCartEntity)
        let request: NSFetchRequest<Tb_CartDetail> = Tb_CartDetail.fetchRequest()
        request.predicate = filterAtt
        do {
            let cartDetail = try self.mainContext.fetch(request).first
            return cartDetail
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func emptyCart() {
        if let cartEntity = self.mainEmployeeEntity?.toCart {
            cartEntity.toCartDetail = nil
            cartEntity.total = 0
            saveData()
        }
    }
    func updateCartTotal() {
        //Verificamos si existe carrito para el empleado por defecto
        guard let cartEntity = self.mainEmployeeEntity?.toCart else {
            print("El empleado por defecto no tiene carrito")
            return
        }
        //Verificamos si existe detalle del carrito
        guard let cartDetailEntityList = cartEntity.toCartDetail?.compactMap({ $0 as? Tb_CartDetail }) else {
            print("El carrito no tiene detalle")
            cartEntity.total = 0
            saveData()
            return
        }
        cartEntity.total = Double(cartDetailEntityList.reduce(0) {$0 + $1.subtotal})
        saveData()
    }
    func increaceProductAmount (cartDetail: CartDetail) {
        //Verificamos si existe este detalle
        guard let cartDetailEntity = cartDetail.toCartDetailEntity(context: self.mainContext) else {
            print("Detalle de producto no existe en carrito")
            return
        }
        guard let productEntity = cartDetailEntity.toProduct else {
            print("Este detalle de carrito no tiene producto")
            return
        }
        if productEntity.quantityStock > cartDetailEntity.quantityAdded {
            cartDetailEntity.quantityAdded += 1
            cartDetailEntity.subtotal = Double(cartDetailEntity.quantityAdded) * productEntity.unitPrice
        } else {
            print("Producto no tiene stock suficiente")
        }
        updateCartTotal()
        saveData()
    }
    func decreceProductAmount(cartDetail: CartDetail) {
        //Verficamos si existe este detalle
        guard let cartDetailEntity = cartDetail.toCartDetailEntity(context: self.mainContext) else {
            print("Detalle de producto no existe en carrito")
            return
        }
        guard let productEntity = cartDetailEntity.toProduct else {
            print("Este detalle de carrito no tiene producto")
            return
        }
        if cartDetailEntity.quantityAdded > 1 {
            cartDetailEntity.quantityAdded -= 1
            cartDetailEntity.subtotal = Double(cartDetailEntity.quantityAdded) * productEntity.unitPrice
        } else {
            print("La cantida agregada no puede disminuir menos que 0")
        }
        updateCartTotal()
        saveData()
    }
    func getListProductInCart () -> [CartDetail] {
        //Verificamos si existe carrito para el empleado por defecto
        guard let cartEntity = self.mainEmployeeEntity?.toCart else {
            print("El empleado por defecto no tiene carrito")
            return []
        }
        guard let cartDetail = cartEntity.toCartDetail?.compactMap({ $0 as? Tb_CartDetail }) else {
            return []
        }
        return cartDetail.toListCartDetail()
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
