//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI
import CoreData

struct MenuView: View {
    @State private var tabSelected: Tab = .plus
    @State private var isKeyboardVisible: Bool = false
    var body: some View {
        VStack {
            TabView(selection: $tabSelected) {
                AgregarView(isKeyboardVisible: $isKeyboardVisible)
                    .tag(Tab.plus)
                
                ProductView(selectedTab: $tabSelected)
                    .tag(Tab.magnifyingglass)
                
                CarritoView()
                    .tag(Tab.cart)
            }
            Spacer()
            if isKeyboardVisible{
                CustomHideKeyboard()
            }else{
                CustomTabBar(selectedTab: $tabSelected)
            }
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
