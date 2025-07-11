//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/08/23.
//

import SwiftUI

struct MenuView: View {
    @Environment(LogInViewModel.self) var logInViewModel
    @Environment(Router.self) private var router
    @AppStorage("userOrEmail") var userOrEmail: String?
    @AppStorage("password") var password: String?
    @State var menuTab: MenuTab = .pointOfSaleTab
    @State var tab: Tab = .magnifyingglass
    var body: some View {
        @Bindable var router = router
        ZStack {
            SideMenuView(menuTab: $menuTab, showMenu: $router.showMenu)
            ZStack {
                WindowsEffect(showMenu: $router.showMenu)
                menuTab.rootView
                    .onAppear {
                        router.popToRoot()
                    }
                TempViewOverlay(showMenu: $router.showMenu)
            }
            .scaleEffect(router.showMenu ? 0.84 : 1)
            .offset(x: router.showMenu ? getRect().width - 180 : 0)
        }
    }
}

struct TempViewOverlay: View {
    @Binding var showMenu: Bool
    var body: some View {
        VStack(spacing: 0) {
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
        }
    }
}

struct WindowsEffect: View {
    @Binding var showMenu: Bool
    var body: some View {
        ZStack {
            if showMenu {
                Color(.white)
                    .opacity(0.5)
                    .cornerRadius(35)
                    .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                    .offset(x: -25)
                    .padding(.vertical, 30)
                Color(.white)
                    .opacity(0.4)
                    .cornerRadius(35)
                    .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                    .offset(x: -50)
                    .padding(.vertical, 60)
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        @State var menuTab: MenuTab = .pointOfSaleTab
        MenuView()
            .environment(nor.logInViewModel)
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.employeeViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.addCustomerViewModel)
    }
}
