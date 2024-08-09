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
        ZStack(content: {
            if !viewStates.isShowMenu {
                Color("color_primary")
                    .ignoresSafeArea()
            }
            VStack(spacing: 0, content: {
                switch tabSelected {
                case .plus:
                    AgregarView(selectedTab: $tabSelected)
                case .magnifyingglass:
                    CustomProductView(selectedTab: $tabSelected)
                case .cart:
                    CartView(selectedTab: $tabSelected)
                }
                if viewStates.focusedField == nil {
                    CustomTabBar(selectedTab: $tabSelected)
                }
            })
            .padding(.vertical, viewStates.isShowMenu ? 15 : 0)
            .background(Color("color_primary"))
            .cornerRadius(viewStates.isShowMenu ? 35 : 0)
            .padding(.top, viewStates.isShowMenu ? 0 : 1)
            .disabled(viewStates.isShowMenu ? true : false)
            if viewStates.isShowMenu {
                VStack(spacing: 0, content: {
                    Color("color_primary")
                        .opacity(0.001)
                })
                .onTapGesture(perform: {
                    withAnimation(.easeInOut) {
                        viewStates.isShowMenu = false
                    }
                })
                .disabled(viewStates.isShowMenu ? false : true)
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
        PointOfSaleView()
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(nor.versionCheck)
            .environmentObject(nor.viewStates)
    }
}
