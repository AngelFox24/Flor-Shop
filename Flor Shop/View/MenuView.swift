//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI
import CoreData

struct MenuView: View {
    //@Environment(\.managedObjectContext) private var viewContext
    //@FetchRequest(sortDescriptors: []) private var TB_ProductosVar: FetchedResults<TB_Productos>
    @State private var tabSelected: Tab = .magnifyingglass
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $tabSelected) {
                    AgregarView()
                        .tag(Tab.plus)
                    
                    HomeView()
                        .tag(Tab.magnifyingglass)
                    
                    CarritoView()
                        .tag(Tab.cart)
                }
            }
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $tabSelected)
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .environmentObject(ProductoListViewModel())
            .environmentObject(ProductoCoreDataViewModel())
    }
}
