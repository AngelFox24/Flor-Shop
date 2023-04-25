//
//  ProductCoreDataModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 25/04/23.
//

import CoreData
import Foundation

@objc(ProductCoreDataModel)
public class ProductCoreDataModel: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var nombre_producto: String?
    @NSManaged public var cantidad: Double
    @NSManaged public var costo_unitario: Double
    @NSManaged public var precio_unitario: Double
    @NSManaged public var fecha_vencimiento: Date?
    @NSManaged public var tipo: String?
    @NSManaged public var url: String?
    
    //nombre_producto:String, cantidad:Double, costo_unitario: Double, precio_unitario: Double,fecha_vencimiento: Date,tipo: String,url: String
    
    public override func awakeFromInsert() {
            super.awakeFromInsert()
            id = UUID()
        }
}
