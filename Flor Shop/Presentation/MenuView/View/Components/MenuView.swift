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
        MenuView()
            .environmentObject(nor.logInViewModel)
            .environmentObject(dependencies.agregarViewModel)
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.employeeViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.addCustomerViewModel)
            .environmentObject(nor.versionCheck)
            .environmentObject(nor.viewStates)
            .environmentObject(nor.errorState)
            .environmentObject(nor.navManager)
    }
}
