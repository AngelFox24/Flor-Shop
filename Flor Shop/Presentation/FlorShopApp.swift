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
//        FirebaseApp.configure() // Configura Firebase al inicializar la aplicación
    }
    var body: some Scene {
        WindowGroup {
//            let dependencies = Dependencies()
            let normalDependencies = NormalDependencies()
            RootView()
                .environmentObject(normalDependencies.navManager)
                .environmentObject(normalDependencies.loadingState)
                .environmentObject(normalDependencies.versionCheck)
                .environmentObject(normalDependencies.logInViewModel)
//                .onAppear {
//                    Task(priority: .background, operation: {
//                        print("Se optimizara las imagenes")
//                        await dependencies.imageManager.deleteUnusedImages()
//                    })
//                }
        }
    }
}
