//
//  Flor_ShopApp.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI

@main
struct Flor_ShopApp: App {
    
    @StateObject var productosApi = ProductoListViewModel()
    @StateObject var productosCodeData = ProductoCoreDataViewModel()
    @StateObject var productsCodeData = ProductCoreDataViewModel()
    
    var body: some Scene {
        WindowGroup {
            MenuView()
                .environmentObject(productosApi)
                .environmentObject(productosCodeData)
                .environmentObject(productsCodeData)
        }
    }
}
