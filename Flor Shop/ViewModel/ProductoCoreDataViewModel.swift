//
//  ProductoCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/04/23.
//
import CoreData
import Foundation

class ProductoCoreDataViewModel: ObservableObject {
    @Published var productosCoreData: [ProductoEntity] = []
    let productsContainer: NSPersistentContainer
    //= NSPersistentContainer(name: "BDFlor")
    init(){
        //super.init()
        self.productsContainer = NSPersistentContainer(name: "BDFlor")
        self.productsContainer.loadPersistentStores { description,error in
            if let error=error{
                print("Error al cargar datos de CoreData \(error)")
            }else{
                print("Yeeeees")
            }
        }
        fetchProducts()
    }
    //MARK: CRUD Core Data
    func fetchProducts () {
        let request = NSFetchRequest<ProductoEntity>(entityName: "ProductoEntity")
        do{
            self.productosCoreData = try self.productsContainer.viewContext.fetch(request)
        }catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func addProducts (nombre_producto:String, cantidad:String, costo_unitario: String, precio_unitario: String,fecha_vencimiento: String,tipo: String,url: String) {
        
        if isProductNameValid(nombre_producto),isCantidadValid(cantidad, tipo),isCostoUnitarioValid(costo_unitario),isPrecioUnitarioValid(precio_unitario),isFechaVencimientoValid(fecha_vencimiento),isURLValid(url){
            
            let newProduct = ProductoEntity(context: productsContainer.viewContext)
            newProduct.nombre_producto=nombre_producto
            newProduct.cantidad=Double(cantidad)!
            newProduct.costo_unitario=Double(costo_unitario)!
            newProduct.precio_unitario=Double(precio_unitario)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            newProduct.fecha_vencimiento=dateFormatter.date(from: fecha_vencimiento)
            newProduct.tipo=tipo
            newProduct.url=url
            saveData()
            print ("Se guardo en Core Data correctamente!!!")
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
        }
        
    }
    
    func saveData () {
        do{
            try self.productsContainer.viewContext.save()
        }catch let error {
            print("Error saving. \(error)")
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
        
        if let date = dateFormatter.date(from: fechaVencimiento) {
            // la fecha se pudo transformar exitosamente
            return true
        } else {
            // la fecha no se pudo transformar
            return false
        }
    }
    
    func isURLValid(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        return true
    }
}
