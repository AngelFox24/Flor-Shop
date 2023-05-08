//
//  VentasCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 8/05/23.
//
import CoreData
import Foundation


class VentasCoreDataViewModel: ObservableObject {
    @Published var ventasCoreData: [Tb_Venta] = []
    let ventaContainer: NSPersistentContainer
    
    init(){
        self.ventaContainer = NSPersistentContainer(name: "BDFlor")
        self.ventaContainer.loadPersistentStores{descripcion,error in
            if let error=error{
                print("Error al cargar productos vendidos \(error)")
            }else{
                print("Se cargo exitosamente productos vendidos")
            }
        }
        fetchVentas()
    }
    //MARK: CRUD Core Data
    func fetchVentas () {
        let request = NSFetchRequest<Tb_Venta>(entityName: "Tb_Venta")
        do{
            self.ventasCoreData = try self.ventaContainer.viewContext.fetch(request)
        }catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func saveVentas () {
        do{
            try self.ventaContainer.viewContext.save()
        }catch let error {
            print("Error al guardar los detalles de la venta \(error)")
        }
    }
    //TODO: Agregar validaciones y reducciones de stock
    func registrarVenta(carritoEntity: Tb_Carrito){
        let detallesCarrito = carritoEntity.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito>
        
        //Recorremos la lista de detalles del carrito para agregarlo a la venta y reducirlo en los productos
        if let listaCarrito = detallesCarrito {
            let newVenta = Tb_Venta(context: ventaContainer.viewContext)
            newVenta.idVenta = UUID()
            newVenta.fechaVenta = Date()
            newVenta.totalVenta = carritoEntity.totalCarrito //Asignamos el mismo total del carrito a la venta
            for detalleCarrito in listaCarrito {
                if let nsSetIDProducto = detalleCarrito.detalleCarrito_to_producto?.objectID {
                    let productoInContext = ventaContainer.viewContext.object(with: nsSetIDProducto) as! Tb_Producto
                    // Crear el objeto detalleCarrito y establecer sus propiedades
                    let detalleVenta = Tb_DetalleVenta(context: ventaContainer.viewContext)
                    detalleVenta.idDetalleVenta = UUID() // Genera un nuevo UUID para el detalle de la venta
                    detalleVenta.cantidad = detalleCarrito.cantidad //Asignamos la misma cantidad del producto del carrito
                    detalleVenta.subtotal = detalleCarrito.subtotal //Asignamos el mismo subtotal del producto del carrito
                    // Agregar el objeto del producto a detalle de venta
                    detalleVenta.detalleVenta_to_producto = productoInContext
                    // Agregar el objeto detalleVenta a la venta
                    detalleVenta.detalleVenta_to_venta = newVenta
                }
            }
            saveVentas()
            print("Se ha registrado una nueva venta exitosamente \(String(describing: newVenta.idVenta))")
            fetchVentas()
        }else{
            print("No hay elementos para vender")
        }
    }
}

