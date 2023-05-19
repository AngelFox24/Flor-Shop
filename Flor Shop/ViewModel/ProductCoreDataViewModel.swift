//
//  ProductCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/05/23.
//

import CoreData
import Foundation

class ProductCoreDataViewModel: ObservableObject {
    @Published var productsCoreData: [Tb_Producto] = []
    let productsContainer: NSPersistentContainer
    
    init(){
        self.productsContainer = NSPersistentContainer(name: "BDFlor")
        self.productsContainer.loadPersistentStores { description,error in
            if let error=error{
                print("Error al cargar datos de CoreData Nuevo Modelo \(error)")
            }else{
                print("Yeeeees")
            }
        }
        fetchProducts()
    }
    //MARK: CRUD Core Data
    func fetchProducts () {
        let request: NSFetchRequest<Tb_Producto> = Tb_Producto.fetchRequest()
        do{
            self.productsCoreData = try self.productsContainer.viewContext.fetch(request)
        }catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func addProduct (nombre_producto:String, cantidad:String, costo_unitario: String, precio_unitario: String,fecha_vencimiento: String,tipo: String,url: String) -> Bool{
        
        if isProductNameValid(nombre_producto),isCantidadValid(cantidad, tipo),isCostoUnitarioValid(costo_unitario),isPrecioUnitarioValid(precio_unitario),isFechaVencimientoValid(fecha_vencimiento),isURLValid(url){
            print ("El nombre del contenedor xd: \(self.productsContainer.name)")
            let newProduct = Tb_Producto(context: productsContainer.viewContext)
            newProduct.idProducto = UUID()
            newProduct.nombreProducto=nombre_producto
            newProduct.cantidadStock=Double(cantidad)!
            newProduct.costoUnitario=Double(costo_unitario)!
            newProduct.precioUnitario=Double(precio_unitario)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            newProduct.fechaVencimiento=dateFormatter.date(from: fecha_vencimiento)
            newProduct.tipoMedicion=tipo
            newProduct.url=url
            fetchProducts()
            saveData()
            print ("Se guardo en Core Data correctamente!!!")
            return true
        }else{
            print ("No se pudo guardar en Core Data correctamente!!!")
            if !isProductNameValid(nombre_producto){
                print ("El nombre del producto esta mal \(nombre_producto)")
            }
            else if !isCantidadValid(cantidad,tipo){
                print ("La cantidad y el tipo esta mal \(cantidad) \(tipo)")
            }
            else if !isCostoUnitarioValid(costo_unitario){
                print ("El costo unitario esta mal \(costo_unitario)")
            }
            else if !isPrecioUnitarioValid(precio_unitario){
                print ("El precio unitario esta mal \(precio_unitario)")
            }
            else if !isFechaVencimientoValid(fecha_vencimiento){
                print ("La fecha de vencimiento esta mal \(fecha_vencimiento)")
            }
            else if !isURLValid(url){
                print ("La URL esta mal \(url)")
            }
            return false
        }
        
    }
    
    func reducirStock (carritoDeCompras: Tb_Carrito?) -> Bool {
        var guardarCambios:Bool = true
        if let listaCarrito = carritoDeCompras?.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> {
            for detalleCarrito in listaCarrito {
                let cantidadReducida:Double = detalleCarrito.cantidad
                let productosFiltrados = productsCoreData.filter { $0.idProducto == detalleCarrito.detalleCarrito_to_producto?.idProducto }
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
            fetchProducts()
            saveData()
        }else{
            print ("Eliminamos los cambios")
            self.productsContainer.viewContext.rollback()
        }
        return guardarCambios
    }
    
    func deleteProduct (indexSet: IndexSet) {
        do{
            try self.productsContainer.viewContext.save()
        }catch let error {
            print("Error saving. \(error)")
        }
    }
    
    func saveData () {
        do{
            print ("Se esta guardando en ProductCoreDataViewModel. \(self.productsContainer.viewContext)")
            try self.productsContainer.viewContext.save()
        }catch let error as NSError {
            print("Error saving. \(error)")
            if let conflictList = error.userInfo[NSPersistentStoreSaveConflictsErrorKey] as? [NSMergeConflict] {
                    // Itera sobre la lista de conflictos
                    for mergeConflict in conflictList {
                        // Aquí tienes una instancia de NSMergeConflict
                        // Puedes pasarla a tu función de resolución de conflictos
                        print ("Se pasa a la resolucion de conflictos")
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
        let conflictingObject = mergeConflict.objectSnapshot
        let entity = sourceObject.entity
        let attributeNames = entity.attributesByName.keys
        print("Lista de atributos:")
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
