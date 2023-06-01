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
    var body: some View {
        VStack {
            TabView(selection: $tabSelected) {
                AgregarView()
                    .tag(Tab.plus)
                
                ProductView()
                    .tag(Tab.magnifyingglass)
                
                CarritoView()
                    .tag(Tab.cart)
            }
            CustomTabBar(selectedTab: $tabSelected)
                .ignoresSafeArea(.keyboard)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
