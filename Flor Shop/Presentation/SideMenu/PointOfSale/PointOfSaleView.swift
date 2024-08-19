//
//  PointOfSaleView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/08/23.
//

import SwiftUI

struct PointOfSaleView: View {
    @State var tabSelected: Tab = .plus
    @EnvironmentObject var viewStates: ViewStates
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    var body: some View {
        ZStack {
            if !viewStates.isShowMenu {
                VStack(spacing: 0, content: {
                    Color("color_primary")
                    Color("color_background")
                })
                .ignoresSafeArea()
            }
            VStack(spacing: 0) {
                TabView(selection: $tabSelected) {
                    AgregarView(selectedTab: $tabSelected)
                        .tabItem {
                            Label("Agregar", systemImage: "plus")
                        }
                        .tag(Tab.plus)
                    CustomProductView(selectedTab: $tabSelected)
                        .tabItem {
                            Label("Buscar", systemImage: "magnifyingglass")
                        }
                        .tag(Tab.magnifyingglass)
                    CartView(selectedTab: $tabSelected)
                        .tabItem {
                            Label("Carro", systemImage: "cart")
                        }
                        .tag(Tab.cart)
                }
            }
            .padding(.vertical, viewStates.isShowMenu ? 15 : 0)
            .background(Color("color_primary"))
            .cornerRadius(viewStates.isShowMenu ? 35 : 0)
            .padding(.top, viewStates.isShowMenu ? 0 : 1)
            .disabled(viewStates.isShowMenu ? true : false)
            .accentColor(Color("color_accent"))
        }
    }
}
struct PointOfSaleView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isKeyboardVisible: Bool = false
        @State var showMenu: Bool = false
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        PointOfSaleView()
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(nor.versionCheck)
            .environmentObject(nor.viewStates)
            .environmentObject(nor.errorState)
    }
}
