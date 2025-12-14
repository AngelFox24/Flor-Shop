import SwiftUI

struct CustomersView: View {
    @State var customerViewModel: CustomerViewModel
    let showMenu: () -> Void
    init(ses: SessionContainer, showMenu: @escaping () -> Void) {
        self.customerViewModel = CustomerViewModelFactory.getCustomerViewModelFactory(sessionContainer: ses)
        self.showMenu = showMenu
    }
    var body: some View {
        ZStack {
            CustomerListController(customerViewModel: $customerViewModel)
            VStack {
                CustomerTopBar(customerViewModel: $customerViewModel, showMenu: showMenu)
                Spacer()
                BottomBar(findText: $customerViewModel.searchWord, addDestination: .addCustomer)
            }
        }
        .padding(.horizontal, 10)
        .task {
            customerViewModel.lazyFetchList()
        }
    }
}

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    CustomersView(ses: SessionContainer.preview, showMenu: {})
        .environment(mainRouter)
}

struct CustomerListController: View {
    @Binding var customerViewModel: CustomerViewModel
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if customerViewModel.customerList.count == 0 {
                    EmptyView(
                        imageName: "groundhog_finding",
                        text: "No hay clientes registrados aún.",
                        textButton: "Agregar",
                        pushDestination: .addCustomer
                    )
                } else {
                    List {
                        ForEach(customerViewModel.customerList) { customer in
                            if let customerCic = customer.customerCic {
                                NavigationButton(push: .customerHistory(customerCic: customerCic)) {
                                    CardViewTipe2(
                                        imageUrl: customer.imageUrl,
                                        topStatusColor: nil,
                                        topStatus: nil,
                                        mainText: customer.name + " " + (customer.lastName ?? ""),
                                        mainIndicatorPrefix: "S/. ",
                                        mainIndicator: String(format: "%.2f", customer.totalDebt.soles),
                                        mainIndicatorAlert: customer.isCreditLimit,
                                        secondaryIndicatorSuffix: nil,
                                        //TODO: poner en variable calculada
                                        //String(customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month))) : nil,
                                        secondaryIndicator: nil,
                                        //TODO: poner en variable calculada
                                        //customer.isDateLimitActive ? String(customer.dateLimit.getDateComponent(dateComponent: .day)) : nil,
                                        secondaryIndicatorAlert: customer.isDateLimit,
                                        size: 80
                                    )
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                                .listRowBackground(Color.background)
                            }
                        }
                    }
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 32) // margen superior
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 32) // margen inferior
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .listStyle(PlainListStyle())
                }
            }
        }
    }
}
