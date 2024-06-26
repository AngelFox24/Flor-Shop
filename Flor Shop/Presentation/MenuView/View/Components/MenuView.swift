//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/08/23.
//

import SwiftUI

struct MenuView: View {
    @State private var selectedTab: MenuTab = .pointOfSaleTab
    @Binding var showMenu: Bool
    @Binding var isKeyboardVisible: Bool
    @EnvironmentObject var logInViewModel: LogInViewModel
    @EnvironmentObject var navManager: NavManager
    @AppStorage("userOrEmail") var userOrEmail: String?
    @AppStorage("password") var password: String?
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
                VStack(spacing: 0, content: {
                    switch selectedTab {
                    case .pointOfSaleTab:
                        PointOfSaleView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
                    case .salesTab:
                        SalesView(showMenu: $showMenu)
                    case .customersTab:
                        CustomersView(showMenu: $showMenu)
                    case .employeesTab:
                        EmployeeView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
                    case .settingsTab:
                        PointOfSaleView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
                    case .logOut:
                        LockScreenView()
                            .onAppear(perform: {
                                userOrEmail = nil
                                password = nil
                                logInViewModel.logOut()
                                navManager.popToRoot()
                            })
                    }
                })
            }
            .scaleEffect(showMenu ? 0.84 : 1)
            .offset(x: showMenu ? getRect().width - 180 : 0)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        @State var showMenu: Bool = false
        MenuView(showMenu: $showMenu, isKeyboardVisible: .constant(false))
            .environmentObject(dependencies.logInViewModel)
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.employeeViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.versionCheck)
    }
}

struct CornerRadiusModifier: ViewModifier {
    var cornerRadius: CGFloat
    var isEnabled: Bool
    
    func body(content: Content) -> some View {
        if isEnabled {
            return AnyView(content.cornerRadius(cornerRadius))
        } else {
            return AnyView(content)
        }
    }
}

extension View {
    func cornerRadius(_ cornerRadius: CGFloat, isEnabled: Bool) -> some View {
        self.modifier(CornerRadiusModifier(cornerRadius: cornerRadius, isEnabled: isEnabled))
    }
}
