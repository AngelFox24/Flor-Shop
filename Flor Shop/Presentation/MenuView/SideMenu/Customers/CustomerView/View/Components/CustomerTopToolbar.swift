import SwiftUI

struct CustomerTopToolbar: ToolbarContent {
    @Binding var viewModel: CustomerViewModel
    let menuOrders = CustomerOrder.allValues
    let menuFilters = CustomerFilterAttributes.allValues
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Picker("Ordenamiento", selection: $viewModel.order) {
                    ForEach(menuOrders, id: \.self) { orden in
                        Text(orden.longDescription)
                            .tag(orden)
                    }
                }
                Picker("Filtros", selection: $viewModel.filter) {
                    ForEach(menuFilters, id: \.self) { filtro in
                        Text(filtro.description)
                            .tag(filtro)
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}
