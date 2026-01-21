import SwiftUI

struct SideMenuView: View {
    @Environment(SessionManager.self) var sessionManager
    @Binding var menuTab: TabDestination
    let showMenu: () -> Void
    let navTabsIter: [TabDestination] = TabDestination.navTabs()
    var body: some View {
            ZStack {
                Color.accentColor
                    .ignoresSafeArea()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 15, content: {
                        VStack(alignment: .leading, spacing: 15, content: {
                            Image("logo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .background(Color.launchBackground)
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
                                TabButton(tab: tab, selectedTab: $menuTab, showMenu: {
                                    showMenu()
                                })
                            }
                        })
                        Spacer()
                        VStack(alignment: .leading, spacing: 5, content: {
                            Button {
                                self.sessionManager.logout()
                            } label: {
                                LogoutButtonView()
                            }
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

extension TabDestination {
    var description: String {
        switch self {
        case .pointOfSale:
            return "Punto de Venta"
        case .sales:
            return "Ventas"
        case .customers:
            return "Clientes"
        case .employees:
            return "Empleados"
        case .settings:
            return "Ajustes"
        }
    }
    var icon: String {
        switch self {
        case .pointOfSale:
            return "house"
        case .sales:
            return "dollarsign.circle"
        case .customers:
            return "person.2"
        case .employees:
            return "person.text.rectangle"
        case .settings:
            return "gearshape"
        }
    }
    var iconFill: String {
        switch self {
        case .pointOfSale:
            return "house.fill"
        case .sales:
            return "dollarsign.circle.fill"
        case .customers:
            return "person.2.fill"
        case .employees:
            return "person.text.rectangle.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
    static func navTabs() -> [TabDestination] {
        //return [.pointOfSaleTab, .salesTab, .customersTab, .employeesTab, .settingsTab]
        return [.pointOfSale, employees, .sales, .customers]
    }
}

#Preview {
    SideMenuView(menuTab: .constant(.pointOfSale), showMenu: {})
}
