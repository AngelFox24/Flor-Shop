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
    
    func deleteProduct(productoEntity: Tb_Producto) {
        guard let carrito = carritoCoreData, let detalleCarrito = carrito.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> else {
            return
        }
        
        let detalleAEliminar = detalleCarrito.filter { $0.detalleCarrito_to_producto?.idProducto == productoEntity.idProducto }
        if let detalle = detalleAEliminar.first {
            carrito.removeFromCarrito_to_detalleCarrito(detalle)
        }
        
        saveCarritoProducts()
        fetchCarrito()
    }
    
    func addProductoToCarrito(productoEntity: Tb_Producto){
        guard let carrito = carritoCoreData, let context = carrito.managedObjectContext else {
            return
        }
        
        // Obtener el objeto productoEntity del mismo contexto que el carrito
        let productoInContext = context.object(with: productoEntity.objectID) as! Tb_Producto
        
        // Crear el objeto detalleCarrito y establecer sus propiedades
        let detalleCarrito = Tb_DetalleCarrito(context: context)
        detalleCarrito.detalleCarrito_to_producto = productoInContext
        detalleCarrito.idDetalleCarrito = UUID() // Genera un nuevo UUID para el detalle del carrito
        //detalleCarrito.detalleCarrito_to_carrito = carrito // Asigna el ID del carrito existente
        detalleCarrito.cantidad = 1
        detalleCarrito.subtotal = productoInContext.precioUnitario * detalleCarrito.cantidad
        
        
        // Agregar el objeto detalleCarrito al carrito
        carrito.addToCarrito_to_detalleCarrito(detalleCarrito)
        
        
        saveCarritoProducts()
        fetchCarrito()
    }
    
    func saveCarritoProducts () {
        do{
            try self.carritoContainer.viewContext.save()
        }catch let error {
            print("Error al guardar los productos al carrito. \(error)")
        }
    }
}
