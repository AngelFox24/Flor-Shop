//
//  Flor_ShopApp.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI
import CoreData
import Firebase

@main
struct FlorShopApp: App {
    init() {
        FirebaseApp.configure() // Configura Firebase al inicializar la aplicación
    }
    var body: some Scene {
        WindowGroup {
            //Definimos contexto para todos
            let productManager = LocalProductManager(mainContext: CoreDataProvider.shared.viewContext)
            let cartManager = LocalCarManager(mainContext: CoreDataProvider.shared.viewContext)
            let saleManager = LocalSaleManager(mainContext: CoreDataProvider.shared.viewContext)
            
            let productRepository = ProductRepositoryImpl(manager: productManager)
            let productsCoreData = ProductViewModel(productRepository: productRepository)
            let cartRepository = CarRepositoryImpl(manager: cartManager)
            let cartCoreData = CartViewModel(carRepository: cartRepository)
            let salesRepository = SaleRepositoryImpl(manager: saleManager)
            let salesCoreData = SalesViewModel(saleRepository: salesRepository)
            let versionCheck = VersionCheck()
            MenuView()
                .environmentObject(productsCoreData)
                .environmentObject(cartCoreData)
                .environmentObject(salesCoreData)
                .environmentObject(versionCheck)
        }
    }
}
