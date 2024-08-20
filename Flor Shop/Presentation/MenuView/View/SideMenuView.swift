//
//  SideMenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/08/23.
//

import SwiftUI

enum MenuTab: String, CaseIterable {
    case pointOfSaleTab
    case salesTab
    case customersTab
    case employeesTab
    case settingsTab
    case logOut
    var description: String {
        switch self {
        case .pointOfSaleTab:
            return "Punto de Venta"
        case .salesTab:
            return "Ventas"
        case .customersTab:
            return "Clientes"
        case .employeesTab:
            return "Empleados"
        case .settingsTab:
            return "Ajustes"
        case .logOut:
            return "Cerrar Sesión"
        }
    }
    var icon: String {
        switch self {
        case .pointOfSaleTab:
            return "house"
        case .salesTab:
            return "dollarsign.circle"
        case .customersTab:
            return "person.2"
        case .employeesTab:
            return "person.text.rectangle"
        case .settingsTab:
            return "gearshape"
        case .logOut:
            return "rectangle.righthalf.inset.fill.arrow.right"
        }
    }
    var iconFill: String {
        switch self {
        case .pointOfSaleTab:
            return "house.fill"
        case .salesTab:
            return "dollarsign.circle.fill"
        case .customersTab:
            return "person.2.fill"
        case .employeesTab:
            return "person.text.rectangle.fill"
        case .settingsTab:
            return "gearshape.fill"
        case .logOut:
            return "rectangle.righthalf.inset.fill.arrow.right"
        }
    }
    static func navTabs() -> [MenuTab] {
        //return [.pointOfSaleTab, .salesTab, .customersTab, .employeesTab, .settingsTab]
        return [.pointOfSaleTab, .salesTab, .customersTab]
    }
}

struct SideMenuView: View {
    @Binding var menuTab: MenuTab
    @Binding var showMenu: Bool
    @Namespace var animation
    let navTabsIter: [MenuTab] = MenuTab.navTabs()
    var body: some View {
            ZStack {
                Color("color_accent")
                    .ignoresSafeArea()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 15, content: {
                        VStack(alignment: .leading, spacing: 15, content: {
                            Image("logo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .background(Color("colorlaunchbackground"))
                                .frame(width: 80, height: 80)
                                .cornerRadius(15)
                                .padding(.top, 50)
                            VStack(alignment: .leading, spacing: 6, content: {
                                Text("Flor Shop")
                                    .font(.custom("Artifika-Regular", size: 30))
                                    .foregroundColor(Color(.white))
                                /*
                                Text("View Profile")
                                    .font(.custom("Artifika-Regular", size: 15))
                                    .foregroundColor(Color(.white))
                                    .opacity(0.7)
                                 */
                            })
                        })
                        .padding(.leading, 15)
                        VStack(alignment: .leading, spacing: 15, content: {
                            ForEach(navTabsIter, id: \.self) {tab in
                                    TabButton(tab: tab, selectedTab: $menuTab, showMenu: $showMenu)
                            }
                        })
                        Spacer()
                        VStack(alignment: .leading, spacing: 5, content: {
                            //TabButton(tab: MenuTab.logOut, selectedTab: $selectedTab, showMenu: $showMenu)
                            Text("App Version 2.0.2")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .opacity(0.6)
                                .padding(.leading, 15)
                                .padding(.bottom, 10)
                        })
                    })
                    Spacer()
                }
            }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        @State var menuTab: MenuTab = .customersTab
        @State var showMenu: Bool = false
        SideMenuView(menuTab: $menuTab, showMenu: $showMenu)
    }
}
