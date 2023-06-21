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
            
            let productManager = LocalProductManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
            let productRepository = ProductRepositoryImpl(manager: productManager)
            let productsCoreData = ProductViewModel(productRepository: productRepository)
            
            let cartManager = LocalCarManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
            let cartRepository = CarRepositoryImpl(manager: cartManager)
            let cartCoreData = CartViewModel(carRepository: cartRepository)
            
            let saleManager = LocalSaleManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
            let salesRepository = SaleRepositoryImpl(manager: saleManager)
            let salesCoreData = SalesViewModel(saleRepository: salesRepository)
            
            MenuView()
                .environmentObject(productsCoreData)
                .environmentObject(cartCoreData)
                .environmentObject(salesCoreData)
        }
    }
}
