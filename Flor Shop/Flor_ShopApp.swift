//
//  Flor_ShopApp.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI
import CoreData

@main
struct Flor_ShopApp: App {
    let bdFlorContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BDFlor")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error al cargar el almacén persistente de Core Data: \(error)")
            }
        }
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            let productsCoreData = ProductCoreDataViewModel(contenedorBDFlor: bdFlorContainer)
            let carritoCoreData = CarritoCoreDataViewModel(contenedorBDFlor: bdFlorContainer)
            let ventasCoreData = VentasCoreDataViewModel(contenedorBDFlor: bdFlorContainer)
            
            MenuView()
                .environmentObject(productsCoreData)
                .environmentObject(carritoCoreData)
                .environmentObject(ventasCoreData)
        }
    }
}
