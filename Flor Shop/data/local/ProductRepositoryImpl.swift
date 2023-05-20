//
//  ProductRepositoryImpl.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation
import CoreData

//clas
public class ProductRepositoryImpl: ProductRepository {

    let productsContainer: NSPersistentContainer
    
    init(contenedorBDFlor: NSPersistentContainer){
        self.productsContainer = contenedorBDFlor
    }
    
    
    func getListProducts() -> [Tb_Producto] {
        var productList: [Tb_Producto] = []
        let request: NSFetchRequest<Tb_Producto> = Tb_Producto.fetchRequest()
        do{
            productList = try self.productsContainer.viewContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
        return productList
    }
    
    
    func saveProduct(product: Product) -> String {
        var message = ""
        if isProductNameValid(product.name),
           isCantidadValid(product.qty,product.type),
           isCostoUnitarioValid(product.unitCost),
           isPrecioUnitarioValid(product.unitPrice),
           isFechaVencimientoValid(product.expirationDate),
           isURLValid(product.url) {
            
            let newProduct = Tb_Producto(context: productsContainer.viewContext)
            newProduct.idProducto = UUID()
            newProduct.nombreProducto=product.name
            newProduct.cantidadStock=Double(product.qty)!
            newProduct.costoUnitario=Double(product.unitCost)!
            newProduct.precioUnitario=Double(product.unitPrice)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            newProduct.fechaVencimiento=dateFormatter.date(from: product.expirationDate)
            newProduct.tipoMedicion=product.type
            newProduct.url=product.url
            saveData()
            message = "Success"
            
        }else{

            if !isProductNameValid(product.name){
                message = "El nombre del producto esta mal \(product.name)"
            }
            else if !isCantidadValid(product.qty,product.type){
                message = "La cantidad y el tipo esta mal \(product.qty) \(product.type)"
            }
            else if !isCostoUnitarioValid(product.unitCost){
                message = "El costo unitario esta mal \(product.unitCost)"
            }
            else if !isPrecioUnitarioValid(product.unitPrice){
                message = "El precio unitario esta mal \(product.unitPrice)"
            }
            else if !isFechaVencimientoValid(product.expirationDate){
                message = "La fecha de vencimiento esta mal \(product.expirationDate)"
            }
            else if !isURLValid(product.url){
                message = "La URL esta mal \(product.url)"
            }
        }
        return message
        
    }
    
    
    func reduceStock(carritoDeCompras: Tb_Carrito?) -> Bool {
        var guardarCambios:Bool = true
        if let listaCarrito = carritoDeCompras?.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> {
            for detalleCarrito in listaCarrito {
                let cantidadReducida:Double = detalleCarrito.cantidad
                let productosFiltrados = getListProducts().filter { $0.idProducto == detalleCarrito.detalleCarrito_to_producto?.idProducto }
                if let productoEncontrado = productosFiltrados.first {
                    print ("Contexto del producto filtrado \(String(describing: productoEncontrado.managedObjectContext))")
                    print("El nombre: \(String(describing: productoEncontrado.nombreProducto)) Cantidad Stock Antes: \(productoEncontrado.cantidadStock)")
                    if productoEncontrado.cantidadStock >= cantidadReducida {
                        productoEncontrado.cantidadStock -= cantidadReducida
                        print("Se ha disminuido el producto, Cantidad Despues: \(productoEncontrado.cantidadStock)")
                    }else{
                        guardarCambios = false
                    }
                }else {
                    guardarCambios = false
                }
            }
        }
        if guardarCambios {
            saveData()
        }else{
            print ("Eliminamos los cambios")
            self.productsContainer.viewContext.rollback()
        }
        return guardarCambios
    }
    
    
    func deleteProduct(indexSet: IndexSet) -> Bool {
        
        do{
            try self.productsContainer.viewContext.save()
            return true
        }catch let error {
            print("Error saving. \(error)")
            return false
        }
    }
    
    
    func saveData () {
        do{
            try self.productsContainer.viewContext.save()
        }catch let error as NSError {
            if let conflictList = error.userInfo[NSPersistentStoreSaveConflictsErrorKey] as? [NSMergeConflict] {
                    // Itera sobre la lista de conflictos
                    for mergeConflict in conflictList {
                        // Aquí tienes una instancia de NSMergeConflict
                        // Puedes pasarla a tu función de resolución de conflictos
                        resolveMergeConflict(mergeConflict)
                    }
                } else {
                    // Manejar otros errores de guardado de cambios
                }
        }
    }
    
    
    func resolveMergeConflict(_ mergeConflict: NSMergeConflict) {
        // Accede a los objetos en conflicto
        let sourceObject = mergeConflict.sourceObject
        //let conflictingObject = mergeConflict.objectSnapshot
        let entity = sourceObject.entity
        let attributeNames = entity.attributesByName.keys

        for attributeName in attributeNames {
            print(attributeName)
        }
        // Realiza los cambios necesarios para resolver el conflicto
        // Esto puede implicar combinar cambios, seleccionar uno u otro, etc.
        // Marca el conflicto como resuelto
        // Esto puede implicar marcar un atributo o establecer una propiedad específica
        
        // Guarda los cambios en el contexto de Core Data
        do {
            try sourceObject.managedObjectContext?.save()
        } catch {
            print("Error al guardar los cambios después de resolver el conflicto: \(error)")
        }
    }
    
    
    
    
    
    
    //MARK: Validacion Crear Producto
    func isProductNameValid(_ productName: String) -> Bool {
        return !productName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func isCantidadValid(_ cantidad: String,_ tipo: String) -> Bool {
        if tipo == "Uni"{
            if let cantidadInt = Int(cantidad), cantidadInt > 0 {
                return true
            } else {
                return false
            }
        }else if tipo == "Kg"{
            if let cantidadDouble = Double(cantidad), cantidadDouble > 0.0 {
                return true
            } else {
                return false
            }
        }else{
            return false
        }
    }
    
    func isCostoUnitarioValid(_ costoUnitario: String) -> Bool {
        if let costoUnitarioDouble = Double(costoUnitario),costoUnitarioDouble>0.0 {
            return true
        } else {
            return false
        }
    }
    
    func isPrecioUnitarioValid(_ precioUnitario: String) -> Bool {
        if let precioUnitarioDouble = Double(precioUnitario),precioUnitarioDouble>0.0 {
            return true
        } else {
            return false
        }
    }
    
    func isFechaVencimientoValid(_ fechaVencimiento: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // formato esperado de la fecha
        
        if dateFormatter.date(from: fechaVencimiento) != nil {
            // la fecha se pudo transformar exitosamente
            return true
        } else {
            // la fecha no se pudo transformar
            return false
        }
    }
    
    func isURLValid(_ urlString: String) -> Bool {
        guard URL(string: urlString) != nil else {
            return false
        }
        return true
    }
    
    
    
    
    
    
}
