//
//  PointOfSaleView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/08/23.
//

import SwiftUI

struct PointOfSaleView: View {
    @State var tabSelected: Tab = .magnifyingglass
    @Binding var isKeyboardVisible: Bool
    @Binding var showMenu: Bool
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    var body: some View {
        ZStack(content: {
            if !showMenu {
                Color("color_primary")
                    .ignoresSafeArea()
            }
            VStack(spacing: 0, content: {
                switch tabSelected {
                case .plus:
                    AgregarView(selectedTab: $tabSelected, showMenu: $showMenu)
                case .magnifyingglass:
                    ProductView(selectedTab: $tabSelected, showMenu: $showMenu)
                case .cart:
                    CartView(selectedTab: $tabSelected, showMenu: $showMenu)
                }
                if !isKeyboardVisible {
                    CustomTabBar(selectedTab: $tabSelected)
                }
            })
            .padding(.vertical, showMenu ? 15 : 0)
            .background(Color("color_primary"))
            .cornerRadius(showMenu ? 35 : 0)
            .padding(.top, showMenu ? 0 : 1)
            .disabled(showMenu ? true : false)
            if showMenu {
                VStack(spacing: 0, content: {
                    Color("color_primary")
                        .opacity(0.001)
                })
                .onTapGesture(perform: {
                    withAnimation(.easeInOut) {
                        showMenu = false
                    }
                })
                .disabled(showMenu ? false : true)
            }
        })
    }
}
struct PointOfSaleView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isKeyboardVisible: Bool = false
        @State var showMenu: Bool = false
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        PointOfSaleView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(nor.versionCheck)
    }
}
