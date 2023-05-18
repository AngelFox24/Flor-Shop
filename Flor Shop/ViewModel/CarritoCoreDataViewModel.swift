//
//  CarritoCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/05/23.
//
import CoreData
import Foundation


class CarritoCoreDataViewModel: ObservableObject {
    @Published var carritoCoreData: Tb_Carrito?
    let carritoContainer: NSPersistentContainer
    
    init(){
        self.carritoContainer = NSPersistentContainer(name: "BDFlor")
        self.carritoContainer.loadPersistentStores{descripcion,error in
            if let error=error{
                print("Error al cargar productos del carrito \(error)")
            }else{
                print("Se cargo exitosamente productos del carrito")
            }
        }
        fetchCarrito()
    }
    //MARK: CRUD Core Data
    func fetchCarrito() {
        let request: NSFetchRequest<Tb_Carrito> = Tb_Carrito.fetchRequest()
        do{
            let results = try self.carritoContainer.viewContext.fetch(request).first
            if results == nil {
                let idCarrito = UUID()
                let fechaCarrito = Date()
                let totalCarrito = 0.0
                
                carritoCoreData = Tb_Carrito(context: self.carritoContainer.viewContext)
                carritoCoreData?.idCarrito = idCarrito
                carritoCoreData?.fechaCarrito = fechaCarrito
                carritoCoreData?.totalCarrito = totalCarrito
                
                saveCarritoProducts()
                print("Se creo un nuevo carrito exitosamente \(idCarrito)")
            }else{
                self.carritoCoreData = results
                print("El carrito ya esta creado")
            }
        }catch let error{
            print("Error al recuperar el carrito de productos \(error)")
        }
    }
    
    func saveCarritoProducts () {
        do{
            print("Se esta guardando en CarritoCoreDataViewModel. \(self.carritoContainer.viewContext)")
            try self.carritoContainer.viewContext.save()
        }catch let error {
            print("Error al guardar los productos al carrito. \(error)")
        }
    }
    
    //Elimina un producto del carrito de compras
    func deleteProduct(productoEntity: Tb_Producto) {
        guard let carrito = carritoCoreData, let detalleCarrito = carrito.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        
        let detalleAEliminar = detalleCarrito.filter { $0.detalleCarrito_to_producto?.idProducto == productoEntity.idProducto }
        if let detalle = detalleAEliminar.first {
            carrito.removeFromCarrito_to_detalleCarrito(detalle)
        }
        updateTotalCarrito()
        saveCarritoProducts()
        fetchCarrito()
    }
    
    func addProductoToCarrito(productoEntity: Tb_Producto){
        guard let carrito = carritoCoreData else {
            return
        }
        let context = carritoContainer.viewContext
        
        // Obtener el objeto productoEntity del mismo contexto que el carrito
        let productoInContext = context.object(with: productoEntity.objectID) as! Tb_Producto
        
        // Crear el objeto detalleCarrito y establecer sus propiedades
        let detalleCarrito = Tb_DetalleCarrito(context: context)
        detalleCarrito.idDetalleCarrito = UUID() // Genera un nuevo UUID para el detalle del carrito
        //detalleCarrito.detalleCarrito_to_carrito = carrito // Asigna el ID del carrito existente
        detalleCarrito.cantidad = 1
        detalleCarrito.subtotal = productoInContext.precioUnitario * detalleCarrito.cantidad
        // Agregar el objeto producto al detalle carrito
        detalleCarrito.detalleCarrito_to_producto = productoInContext
        // Agregar el objeto detalleCarrito al carrito
        detalleCarrito.detalleCarrito_to_carrito = carrito
        
        updateTotalCarrito()
        fetchCarrito()
        saveCarritoProducts()
    }
    
    func vaciarCarrito (){
        carritoCoreData?.carrito_to_detalleCarrito = nil
        
        updateTotalCarrito()
        fetchCarrito()
        saveCarritoProducts()
    }
    
    func updateTotalCarrito(){
        guard let carrito = carritoCoreData, let detalleCarrito = carrito.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        var Total:Double = 0.0
        for producto in detalleCarrito {
            print("Producto nombre: \(String(describing: producto.detalleCarrito_to_producto?.nombreProducto)) y su precioUnitario: \(String(describing: producto.detalleCarrito_to_producto?.precioUnitario))")
            print("Total antes \(Total)")
            Total += producto.cantidad * (producto.detalleCarrito_to_producto?.precioUnitario ?? 0.0)
            print("Total despues \(Total)")
        }
        carrito.totalCarrito = Total
        fetchCarrito()
    }
    
    func increaceProductAmount (productoEntity: Tb_Producto){
        print("Se presiono incrementar cantidad")
        guard let carrito = carritoCoreData, let detalleCarrito = carrito.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        
        let detalleAAgregar = detalleCarrito.filter { $0.detalleCarrito_to_producto?.idProducto == productoEntity.idProducto }
        if let detalle = detalleAAgregar.first {
            print("El nombre: \(String(describing: detalle.detalleCarrito_to_producto?.nombreProducto)) Cantidad Antes: \(detalle.cantidad)")
            detalle.cantidad += 1.0
            print("Cantidad Despues: \(detalle.cantidad)")
        }
        updateTotalCarrito()
        fetchCarrito()
        saveCarritoProducts()
    }
    
    func decreceProductAmount (productoEntity: Tb_Producto){
        print("Se presiono reducir cantidad")
        guard let carrito = carritoCoreData, let detalleCarrito = carrito.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        
        let detalleAAgregar = detalleCarrito.filter { $0.detalleCarrito_to_producto?.idProducto == productoEntity.idProducto }
        if let detalle = detalleAAgregar.first {
            print("El nombre: \(String(describing: detalle.detalleCarrito_to_producto?.nombreProducto)) Cantidad Antes: \(detalle.cantidad)")
            detalle.cantidad -= 1.0
            print("Cantidad Despues: \(detalle.cantidad)")
        }
        updateTotalCarrito()
        fetchCarrito()
        saveCarritoProducts()
    }
}
