import SwiftUI

struct SalesTopToolbar: ToolbarContent {
    @Binding var salesViewModel: SalesViewModel
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Ordenamiento", selection: $salesViewModel.order) {
                    ForEach(SalesOrder.allValues, id: \.self) { order in
                        Text(order.longDescription)
                            .tag(order)
                    }
                }
                Picker("Agrupamiento", selection: $salesViewModel.grouper) {
                    ForEach(SalesGrouperAttributes.allValues, id: \.self) { grouper in
                        Text(grouper.description)
                            .tag(grouper)
                    }
                }
                Picker("Filtro", selection: $salesViewModel.salesDateInterval) {
                    ForEach(SalesDateInterval.allValues, id: \.self) { filter in
                        Text(filter.description)
                            .tag(filter)
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
    }
}
