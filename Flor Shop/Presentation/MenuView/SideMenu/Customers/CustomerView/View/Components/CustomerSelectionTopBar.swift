import SwiftUI

struct CustomerSelectionTopBar: View {
    @Binding var customerViewModel: CustomerViewModel
    let backAction: () -> Void
    var body: some View {
        HStack {
            BackButton(backAction: backAction)
            Spacer()
            Menu {
                Section("Ordenamiento") {
                    ForEach(CustomerOrder.allValues, id: \.self) { orden in
                        Button {
                            customerViewModel.order = orden
                        } label: {
                            Label(orden.longDescription, systemImage: customerViewModel.order == orden ? "checkmark" : "")
                        }
                    }
                }
                Section("Filtros") {
                    ForEach(CustomerFilterAttributes.allValues, id: \.self) { filter in
                        Button {
                            customerViewModel.filter = filter
                        } label: {
                            Label(filter.description, systemImage: customerViewModel.filter == filter ? "checkmark" : "")
                        }
                    }
                }
            } label: {
                FilterButton()
            }
            .onChange(of: customerViewModel.order) { _, _ in
                self.customerViewModel.updateUI()
            }
            .onChange(of: customerViewModel.filter) { _, _ in
                self.customerViewModel.updateUI()
            }
        }
    }
    func setOrder(order: CustomerOrder) {
        customerViewModel.setOrder(order: order)
    }
    func setFilter(filter: CustomerFilterAttributes) {
        customerViewModel.setFilter(filter: filter)
        print("Se presiono setFilter")
    }
}

#Preview {
    @Previewable @State var customerViewModel = CustomerViewModelFactory.getCustomerViewModelFactory(sessionContainer: SessionContainer.preview)
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    CustomerSelectionTopBar(customerViewModel: $customerViewModel, backAction: {})
        .environment(mainRouter)
        .background(Color.primary)
}
