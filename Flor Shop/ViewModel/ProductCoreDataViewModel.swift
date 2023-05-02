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
        //super.init()
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
        let request = NSFetchRequest<Tb_Producto>(entityName: "Tb_Producto")
        do{
            self.productsCoreData = try self.productsContainer.viewContext.fetch(request)
        }catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func addProduct (nombre_producto:String, cantidad:String, costo_unitario: String, precio_unitario: String,fecha_vencimiento: String,tipo: String,url: String) -> Bool{
        
        if isProductNameValid(nombre_producto),isCantidadValid(cantidad, tipo),isCostoUnitarioValid(costo_unitario),isPrecioUnitarioValid(precio_unitario),isFechaVencimientoValid(fecha_vencimiento),isURLValid(url){
            
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
            saveData()
            fetchProducts()
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
    
    func deleteProduct (indexSet: IndexSet) {
        do{
            try self.productsContainer.viewContext.save()
        }catch let error {
            print("Error saving. \(error)")
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
