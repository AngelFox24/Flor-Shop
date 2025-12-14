import SwiftUI

struct MenuView: View {
    @Environment(SessionContainer.self) var sessionContainer
    @State var mainRouter = FlorShopRouter(level: 0, identifierTab: nil)
    @State var showMenu: Bool = false
    var body: some View {
        ZStack {
            SideMenuView(menuTab: $mainRouter.selectedTab, showMenu: changeShowMenu)
            ZStack {
                WindowsEffect(showMenu: $showMenu)
                switch mainRouter.selectedTab {
                case .pointOfSale:
                    NavigationContainer(parentRouter: mainRouter, tab: .pointOfSale, showMenu: $showMenu) {
                        SaleProductView(ses: sessionContainer, showMenu: changeShowMenu)
                    }
                case .customers:
                    NavigationContainer(parentRouter: mainRouter, tab: .customers, showMenu: $showMenu) {
                        CustomersView(ses: sessionContainer, showMenu: changeShowMenu)
                    }
                case .employees:
                    NavigationContainer(parentRouter: mainRouter, tab: .employees, showMenu: $showMenu) {
                        EmployeeView(ses: sessionContainer, showMenu: changeShowMenu)
                    }
                case .sales:
                    NavigationContainer(parentRouter: mainRouter, tab: .sales, showMenu: $showMenu) {
                        SalesView(ses: sessionContainer, showMenu: changeShowMenu)
                    }
                case .settings:
                    Text("Not implemented")
                }
                TempViewOverlay(showMenu: $showMenu)
            }
            .scaleEffect(showMenu ? 0.84 : 1)
            .offset(x: showMenu ? getRect().width - 180 : 0)
        }
        .ignoresSafeArea()
    }
    func changeShowMenu() {
        withAnimation(.easeInOut) {
            showMenu.toggle()
        }
    }
}

struct TempViewOverlay: View {
    @Binding var showMenu: Bool
    var body: some View {
        VStack(spacing: 0) {
            if showMenu {
                VStack(spacing: 0, content: {
                    Color.primary
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

#Preview {
    @Previewable @State var webSocket: SyncWebSocketClient = SyncWebSocketClient(
        synchronizerDBUseCase: SynchronizerDBInteractorMock(),
        lastTokenByEntities: LastTokenByEntities(
            company: 1,
            subsidiary: 1,
            customer: 1,
            employee: 1,
            product: 1,
            sale: 1,
            productSubsidiary: 1,
            employeeSubsidiary: 1
        )
    )
    let session = SessionContainer.preview
    MenuView()
        .environment(session)
        .environment(webSocket)
}
