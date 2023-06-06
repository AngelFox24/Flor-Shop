//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI
import CoreData

struct MenuView: View {
    @State private var tabSelected: Tab = .magnifyingglass
    var body: some View {
        VStack {
            TabView(selection: $tabSelected) {
                AgregarView()
                    .tag(Tab.plus)
                
                ProductView(selectedTab: $tabSelected)
                    .tag(Tab.magnifyingglass)
                
                CarritoView()
                    .tag(Tab.cart)
            }
            Spacer()
            CustomTabBar(selectedTab: $tabSelected)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let prdManager = LocalProductManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let repository = ProductRepositoryImpl(manager: prdManager)
        MenuView()
            .environmentObject(ProductCoreDataViewModel(productRepository: repository))
    }
}
