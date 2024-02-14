//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/08/23.
//

import SwiftUI

struct MenuView: View {
    @State private var selectedTab: MenuTab = .employeesTab
    @State private var showMenu: Bool = false
    @Binding var isKeyboardVisible: Bool
    @State private var tabSelected: Tab = .magnifyingglass
    var body: some View {
        ZStack {
            SideMenuView(selectedTab: $selectedTab, showMenu: $showMenu)
            ZStack {
                if showMenu {
                    Color(.white)
                        .opacity(0.5)
                        .cornerRadius(showMenu ? 35 : 0)
                        .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                        .offset(x: showMenu ? -25 : 0)
                        .padding(.vertical, 30)
                    Color(.white)
                        .opacity(0.4)
                        .cornerRadius(showMenu ? 35 : 0)
                        .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                        .offset(x: showMenu ? -50 : 0)
                        .padding(.vertical, 60)
                }
                if !showMenu {
                    Color("color_primary")
                        .ignoresSafeArea()
                }
                //NavigationStack(path: $menuNavManager.bodyPaths) {
                    switch selectedTab {
                    case .pointOfSaleTab:
                        PointOfSaleView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
                            .cornerRadius(showMenu ? 35 : 0)
                            .padding(.top, showMenu ? 0 : 1)
                            .disabled(showMenu ? true : false)
                        //.ignoresSafeArea()
                    case .salesTab:
                        SalesView(showMenu: $showMenu)
                            .cornerRadius(showMenu ? 35 : 0)
                            .padding(.top, showMenu ? 0 : 1)
                            .disabled(showMenu ? true : false)
                    case .customersTab:
                        CustomersView(showMenu: $showMenu)
                            .cornerRadius(showMenu ? 35 : 0)
                            .padding(.top, showMenu ? 0 : 1)
                            .disabled(showMenu ? true : false)
                    case .employeesTab:
                        EmployeeView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
                            .cornerRadius(showMenu ? 35 : 0)
                            .padding(.top, showMenu ? 0 : 1)
                            .disabled(showMenu ? true : false)
                        //.ignoresSafeArea()
                    case .settingsTab:
                        PointOfSaleView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
                            .cornerRadius(showMenu ? 35 : 0)
                            .padding(.top, showMenu ? 0 : 1)
                            .disabled(showMenu ? true : false)
                    case .logOut:
                        PointOfSaleView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
                            .cornerRadius(showMenu ? 35 : 0)
                            .padding(.top, showMenu ? 0 : 1)
                            .disabled(showMenu ? true : false)
                    }
                //}
            }
            .scaleEffect(showMenu ? 0.84 : 1)
            .offset(x: showMenu ? getRect().width - 120 : 0)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        MenuView(isKeyboardVisible: .constant(true))
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.employeeViewModel)
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.versionCheck)
    }
}