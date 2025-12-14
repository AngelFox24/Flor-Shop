import Foundation
import CoreData

protocol LocalCartManager {
    func getCart() throws -> Car?
    func deleteCartDetail(cartDetail: CartDetail) throws
    func addProductToCart(productIn: Product) throws
    func changeProductAmountInCartDetail(productCic: String, amount: Int) throws
    func emptyCart() throws
}

class LocalCartManagerImpl: LocalCartManager {
    let mainContext: NSManagedObjectContext
    let sessionConfig: SessionConfig
    let className = "LocalCartManager"
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
        guard let cartDetailEntity = try self.sessionConfig.getCartDetailEntityById(context: self.mainContext, cartDetailId: cartDetail.id) else {
            print("Detalle de producto no existe en carrito")
            return
        }
        self.mainContext.delete(cartDetailEntity)
        try saveData()
    }
    func addProductToCart(productIn: Product) throws {
//        try ensureCartExist()
        var success: Bool = false
        guard let cartEntity = try getCartEntity() else {
            print("Empleado por defecto no tiene carrito")
            throw LocalStorageError.entityNotFound("Empleado por defecto no tiene carrito")
        }
        guard let productCic = productIn.productCic else {
            print("Product a agregar no tiene CIC")
            throw LocalStorageError.entityNotFound("Product a agregar no tiene CIC")
        }
        guard let productSubsidiaryEntity = try self.sessionConfig.getProductSubsidiaryEntityByCic(context: self.mainContext, productCic: productCic) else {
            print("El producto a agregar al carrito no existe en la BD local para esta subsidiaria")
            throw LocalStorageError.entityNotFound("El producto a agregar al carrito no existe en la BD local para esta subsidiaria")
        }
        if let cartDetailEntity = try getCartDetail(productCic: productCic) {
            try changeProductAmountInCartDetail(productCic: productCic, amount: Int(cartDetailEntity.quantityAdded) + 1)
            success = true
        } else {
            // Validamos si tiene sificiente Stock
            if productIn.qty >= 1 {
                let newCarDetail = Tb_CartDetail(context: self.mainContext)
                newCarDetail.idCartDetail = UUID() // Genera un nuevo UUID para el detalle del carrito
                newCarDetail.quantityAdded = 1
                newCarDetail.toProductSubsidiary = productSubsidiaryEntity
                newCarDetail.toCart = cartEntity
                success = true
            } else {
                print("No hay stock suficiente: \(productIn.qty)")
                success = false
            }
        }
        if success {
            try saveData()
        } else {
            rollback()
        }
    }
    func changeProductAmountInCartDetail(productCic: String, amount: Int) throws {
        print("changeProductAmountInCartDetail: productCic: \(productCic), amount: \(amount)")
        guard let cartDetailEntity = try getCartDetail(productCic: productCic) else {
            print("Detalle de producto no existe en carrito")
            throw LocalStorageError.invalidInput("Detalle de producto no existe en carrito")
        }
        guard let productSubsidiaryEntity = cartDetailEntity.toProductSubsidiary else {
            print("Este detalle de carrito no tiene producto")
            throw LocalStorageError.entityNotFound("Este detalle de carrito no tiene producto")
        }
        if productSubsidiaryEntity.quantityStock >= Int64(amount) {
            cartDetailEntity.quantityAdded = Int64(amount)
        } else {
            print("Producto no tiene stock suficiente")
            throw BusinessLogicError.outOfStock("Producto no tiene stock suficiente")
        }
        try saveData()
    }
    func emptyCart() throws {
        guard let employeeSubsidiaryEntity = try self.sessionConfig.getEmployeeSubsidiaryEntityByCic(
            context: self.mainContext,
            employeeCic: self.sessionConfig.employeeCic
        ) else {
            throw LocalStorageError.entityNotFound("No se encontro el empleado en esta sucursal")
        }
        guard let cartEntity = employeeSubsidiaryEntity.toCart else {
            throw LocalStorageError.entityNotFound("El empleado por defecto no tiene carrito asignado")
        }
        if let cartDetails = cartEntity.toCartDetail?.compactMap({ $0 as? Tb_CartDetail }) {
            for cartDetail in cartDetails {
                self.mainContext.delete(cartDetail)
            }
        }
        self.mainContext.delete(cartEntity)
        let newCartEntity = Tb_Cart(context: self.mainContext)
        newCartEntity.idCart = UUID()
        employeeSubsidiaryEntity.toCart = newCartEntity
        try saveData()
    }
    //MARK: Private Functions
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
    private func createCart() throws {
        guard let employeeSubsidiaryEntity = try self.sessionConfig.getEmployeeSubsidiaryEntityByCic(
            context: self.mainContext,
            employeeCic: self.sessionConfig.employeeCic
        ) else {
            print("El empleado en contexto no existe en la BD local")
            let cusError: String = "\(className): No se pudo obtener el empleado de la BD"
            throw LocalStorageError.entityNotFound(cusError)
        }
        let newCart: Tb_Cart = Tb_Cart(context: self.mainContext)
        newCart.idCart = UUID()
        newCart.toEmployeeSubsidiary = employeeSubsidiaryEntity
        try saveData()
    }
    private func getCartEntity() throws -> Tb_Cart? {
//        try ensureCartExist()
        guard let employeeSubsidiaryEntity = try self.sessionConfig.getEmployeeSubsidiaryEntityByCic(
            context: self.mainContext,
            employeeCic: self.sessionConfig.employeeCic
        ) else {
            throw LocalStorageError.entityNotFound("No se encontro la subisidiaria")
        }
        return employeeSubsidiaryEntity.toCart
    }
    private func cartExist() throws -> Bool {
        guard let employeeSubsidiaryEntity = try self.sessionConfig.getEmployeeSubsidiaryEntityByCic(
            context: self.mainContext,
            employeeCic: self.sessionConfig.employeeCic
        ) else {
            throw LocalStorageError.entityNotFound("No se encontro la subisidiaria")
        }
        guard let _ = employeeSubsidiaryEntity.toCart else {
            return false
        }
        return true
    }
//    private func ensureCartExist() throws {
//        if try !cartExist() {
//            try createCart()
//        }
//    }
    private func getCartDetail(productCic: String) throws -> Tb_CartDetail? {
//        try ensureCartExist()
        let request: NSFetchRequest<Tb_CartDetail> = Tb_CartDetail.fetchRequest()
        let predicate = NSPredicate(format: "toProductSubsidiary.productCic == %@", productCic)
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
