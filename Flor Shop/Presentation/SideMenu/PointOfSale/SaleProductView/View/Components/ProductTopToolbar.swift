import SwiftUI

struct ProductTopToolbar: ToolbarContent {
    @Binding var productViewModel: ProductViewModel
    let menuOrders: [PrimaryOrder] = PrimaryOrder.allValues
    let menuFilters: [ProductsFilterAttributes] = ProductsFilterAttributes.allValues
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Picker("Ordenamiento", selection: $productViewModel.primaryOrder) {
                    ForEach(menuOrders, id: \.self) { orden in
                        Text(orden.longDescription)
                            .tag(orden)
                    }
                }
                Picker("Filtros", selection: $productViewModel.filterAttribute) {
                    ForEach(menuFilters, id: \.self) { filtro in
                        Text(filtro.description)
                            .tag(filtro)
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            NavigationButton(push: .cartList) {
                Image(systemName: "cart")
            }
//            .badge(productViewModel.cartCount)
//            .onAppear {
//                print("[ProductTopToolbar] Se pinto el botón de carrito")
//            }
        }
    }
}
