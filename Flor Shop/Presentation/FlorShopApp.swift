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
        //FirebaseApp.configure() // Configura Firebase al inicializar la aplicación
    }
    var body: some Scene {
        WindowGroup {
            let dependencies = Dependencies()
            MainView()
                .environmentObject(dependencies.logInViewModel)
                .environmentObject(dependencies.registrationViewModel)
                .environmentObject(dependencies.agregarViewModel)
                .environmentObject(dependencies.productsViewModel)
                .environmentObject(dependencies.cartViewModel)
                .environmentObject(dependencies.salesViewModel)
                .environmentObject(dependencies.versionCheck)
                //.environmentObject(dependencies.companyViewModel)
                .environmentObject(dependencies.employeeViewModel)
                .environmentObject(dependencies.customerViewModel)
                .environmentObject(dependencies.addCustomerViewModel)
                .environmentObject(dependencies.navManager)
                .environmentObject(dependencies.customerHistoryViewModel)
                .onAppear {
                    Task(priority: .background, operation: {
                        print("Se optimizara las imagenes")
                        await dependencies.imageManager.deleteUnusedImages()
                    })
                }
        }
    }
}
