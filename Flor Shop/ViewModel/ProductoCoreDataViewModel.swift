//
//  ProductoCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/04/23.
//
import CoreData
import Foundation

class ProductoCoreDataViewModel: NSObject,ObservableObject {
    @Published var productosDiccionarioCoreData: [String:ProductoModel] = [String:ProductoModel]()
    let productsContainer: NSPersistentContainer = NSPersistentContainer(name: "BDFlor")
    override init(){
        super.init()
        self.productsContainer.loadPersistentStores { _, _ in }
        
    }
}
