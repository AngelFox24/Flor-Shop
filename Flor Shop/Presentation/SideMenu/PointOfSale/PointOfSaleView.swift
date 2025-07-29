import SwiftUI

struct PointOfSaleView: View {
    @Environment(Router.self) private var router
    @Environment(CartViewModel.self) var cartViewModel
    @State var tab: Tab = .magnifyingglass
    init() {
        UITabBar.appearance().barTintColor = UIColor(named: "color_background")
    }
    var body: some View {
        ZStack {
            if !router.showMenu {
                VStack(spacing: 0, content: {
                    Color("color_primary")
                    Color("color_background")
//                        .ignoresSafeArea(.keyboard)
                })
                .ignoresSafeArea()
            }
            VStack(spacing: 0) {
//                switch tab {
//                case .plus:
//                    AgregarView(loading: $loading, showMenu: $showMenu, tab: $tab)
//                case .magnifyingglass:
//                    CustomProductView(loading: $loading, showMenu: $showMenu, tab: $tab)
//                case .cart:
//                    CartView(loading: $loading, showMenu: $showMenu, tab: $tab)
//                }
                TabView(selection: $tab) {
                    AgregarView(tab: $tab)
                        .tabItem {
                            Label("Agregar", systemImage: "plus")
                        }
                        .tag(Tab.plus)
                    CustomProductView(tab: $tab)
                        .tabItem {
                            Label("Buscar", systemImage: "magnifyingglass")
                        }
                        .tag(Tab.magnifyingglass)
                    CartView(tab: $tab)
                        .badge(cartViewModel.cartCoreData?.cartDetails.count ?? 0)
                        .tabItem {
                            Label("Carro", systemImage: "cart")
                        }
                        .tag(Tab.cart)
                }
                .accentColor(Color("color_accent"))
            }
            .cornerRadius(router.showMenu ? 35 : 0)
            .padding(.top, router.showMenu ? 0 : 1)
            .onAppear {
                Task {
                    await cartViewModel.lazyFetchCart()
                }
            }
//            if !showMenu {
//                VStack {
//                    Spacer()
//                    CustomTabBar(selectedTab: $tab)
//                }
//                .ignoresSafeArea(.keyboard)
//            }
        }
    }
}
struct PointOfSaleView_Previews: PreviewProvider {
    static var previews: some View {
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        PointOfSaleView()
            .environment(dependencies.agregarViewModel)
            .environment(dependencies.productViewModel)
            .environment(dependencies.cartViewModel)
    }
}
