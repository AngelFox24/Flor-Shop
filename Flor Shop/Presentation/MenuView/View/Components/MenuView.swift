//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/08/23.
//

import SwiftUI

struct MenuView: View {
    @State private var selectedTab: MenuTab = .pointOfSaleTab
    @EnvironmentObject var viewStates: ViewStates
    @EnvironmentObject var logInViewModel: LogInViewModel
    @EnvironmentObject var navManager: NavManager
    @AppStorage("userOrEmail") var userOrEmail: String?
    @AppStorage("password") var password: String?
    @State private var tabSelected: Tab = .magnifyingglass
    var body: some View {
        ZStack {
            SideMenuView(selectedTab: $selectedTab)
            ZStack {
                if viewStates.isShowMenu {
                    Color(.white)
                        .opacity(0.5)
                        .cornerRadius(viewStates.isShowMenu ? 35 : 0)
                        .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                        .offset(x: viewStates.isShowMenu ? -25 : 0)
                        .padding(.vertical, 30)
                    Color(.white)
                        .opacity(0.4)
                        .cornerRadius(viewStates.isShowMenu ? 35 : 0)
                        .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                        .offset(x: viewStates.isShowMenu ? -50 : 0)
                        .padding(.vertical, 60)
                }
                VStack(spacing: 0, content: {
                    switch selectedTab {
                    case .pointOfSaleTab:
                        PointOfSaleView()
                    case .salesTab:
                        SalesView()
                    case .customersTab:
                        CustomersView()
                    case .employeesTab:
                        EmployeeView()
                    case .settingsTab:
                        PointOfSaleView()
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
            .scaleEffect(viewStates.isShowMenu ? 0.84 : 1)
            .offset(x: viewStates.isShowMenu ? getRect().width - 180 : 0)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        @State var showMenu: Bool = false
        MenuView()
            .environmentObject(nor.logInViewModel)
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.employeeViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(nor.versionCheck)
            .environmentObject(nor.viewStates)
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
