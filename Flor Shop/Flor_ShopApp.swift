//
//  Flor_ShopApp.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI

@main
struct Flor_ShopApp: App {
    //Tenemos 2 Variables de Entorno
    @StateObject var productosApi = ProductoListViewModel()
    @StateObject var productosCodeData = ProductoCoreDataViewModel()
    var body: some Scene {
        WindowGroup {
            MenuView()
                .environmentObject(productosApi)
                .environment(\.managedObjectContext, productosCodeData.productsContainer.viewContext)
        }
    }
}
