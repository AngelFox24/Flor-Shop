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
            let repository = ProductRepositoryImpl(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
            let productsCoreData = ProductCoreDataViewModel(repo: repository)
            let carritoCoreData = CarritoCoreDataViewModel(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
            let ventasCoreData = VentasCoreDataViewModel(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
            
            MenuView()
                .environmentObject(productsCoreData)
                .environmentObject(carritoCoreData)
                .environmentObject(ventasCoreData)
        }
    }
}
