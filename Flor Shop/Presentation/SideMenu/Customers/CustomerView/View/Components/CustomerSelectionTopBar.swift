import SwiftUI

struct CustomerSelectionTopBar: View {
    @Binding var customerViewModel: CustomerViewModel
    let backAction: () -> Void
    var body: some View {
        VStack {
            HStack(spacing: 10, content: {
                BackButton(backAction: backAction)
                CustomSearchField(text: $customerViewModel.searchWord)
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
                    customerViewModel.fetchListCustomer()
                }
                .onChange(of: customerViewModel.filter) { _, _ in
                    customerViewModel.fetchListCustomer()
                }
            })
            .padding(.horizontal, 10)
        }
        .padding(.bottom, 9)
        .background(Color("color_primary"))
    }
    func setOrder(order: CustomerOrder) {
        customerViewModel.setOrder(order: order)
    }
    func setFilter(filter: CustomerFilterAttributes) {
        customerViewModel.setFilter(filter: filter)
        print("Se presiono setFilter")
    }
}
