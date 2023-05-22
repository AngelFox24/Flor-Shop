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
    
    var body: some Scene {
        
        WindowGroup {
            
            let productManager = LocalProductManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
            let productRepository = ProductRepositoryImpl(manager: productManager)
            let productsCoreData = ProductCoreDataViewModel(repo: productRepository)
            
            let carManager = LocalCarManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
            let carRepository = CarRepositoryImpl(manager: carManager)
            let carritoCoreData = CarritoCoreDataViewModel(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
            
            let saleManager = LocalSaleManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
            let salesRepository = SaleRepositoryImpl(manager: saleManager)
            let ventasCoreData = VentasCoreDataViewModel(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
            
            MenuView()
                .environmentObject(productsCoreData)
                .environmentObject(carritoCoreData)
                .environmentObject(ventasCoreData)
        }
    }
}
