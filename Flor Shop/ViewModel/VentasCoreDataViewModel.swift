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
    
    init(contenedorBDFlor: NSPersistentContainer){
        self.ventaContainer = contenedorBDFlor
        /*self.ventaContainer.loadPersistentStores{descripcion,error in
            if let error=error{
                print("Error al cargar productos vendidos \(error)")
            }else{
                print("Se cargo exitosamente productos vendidos")
            }
        }*/
        fetchVentas()
    }
    //MARK: CRUD Core Data
    func fetchVentas () {
        let request: NSFetchRequest<Tb_Venta> = Tb_Venta.fetchRequest()
        do{
            self.ventasCoreData = try self.ventaContainer.viewContext.fetch(request)
        }catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func saveVentas () {
        do{
            print ("Se esta guardando en VentasCoreDataViewModel. \(self.ventaContainer.viewContext)")
            try self.ventaContainer.viewContext.save()
        }catch let error {
            print("Error al guardar los detalles de la venta \(error)")
        }
    }
    func registrarVenta(carritoEntity: Tb_Carrito?) -> Bool {
        
        //Recorremos la lista de detalles del carrito para agregarlo a la venta
        if let listaCarrito = carritoEntity?.carrito_to_detalleCarrito as? Set<Tb_DetalleCarrito> {
            
            //Creamos un nuevo objeto venta
            let newVenta = Tb_Venta(context: ventaContainer.viewContext)
            newVenta.idVenta = UUID()
            newVenta.fechaVenta = Date()
            newVenta.totalVenta = carritoEntity?.totalCarrito ?? 0.0 //Asignamos el mismo total del carrito a la venta
            
            for detalleCarrito in listaCarrito {
                if let productoInContext = ventaContainer.viewContext.object(with: detalleCarrito.detalleCarrito_to_producto!.objectID) as? Tb_Producto{
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
            fetchVentas()
            return true
        }else{
            return false
        }
    }
}
