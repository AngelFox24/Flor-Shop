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
            ContentView()
        }
    }
}

struct ContentView: View {
    let normalDependencies = NormalDependencies()
    var body: some View {
        RootView()
            .environmentObject(normalDependencies.navManager)
            .environmentObject(normalDependencies.versionCheck)
            .environmentObject(normalDependencies.logInViewModel)
            .environmentObject(normalDependencies.errorState)
//            .environmentObject(normalDependencies.viewStates)
        //                .onAppear {
        //                    Task(priority: .background, operation: {
        //                        print("Se optimizara las imagenes")
        //                        await dependencies.imageManager.deleteUnusedImages()
        //                    })
        //                }
    }
}
