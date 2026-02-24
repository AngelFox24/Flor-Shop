import SwiftUI

struct CustomerView: View {
    @State var customerViewModel: CustomerViewModel
    let showMenu: () -> Void
    init(
        ses: SessionContainer,
        showMenu: @escaping () -> Void
    ) {
        self.customerViewModel = CustomerViewModelFactory.getCustomerViewModelFactory(sessionContainer: ses)
        self.showMenu = showMenu
    }
    var body: some View {
        CustomerListController(customerViewModel: $customerViewModel)
            .padding(.horizontal, 10)
            .navigationTitle("Clientes")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $customerViewModel.searchText, placement: .toolbar)
            .searchToolbarBehavior(.minimize)
            .toolbar {
                LogoToolBar(action: showMenu)
                CustomerTopToolbar(viewModel: $customerViewModel)
                MainBottomToolbar(destination: .addCustomer)
            }
            .task {
                customerViewModel.updateUI()
            }
    }
}

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    CustomerView(ses: SessionContainer.preview, showMenu: {})
        .environment(mainRouter)
}

struct CustomerListController: View {
    @Environment(FlorShopRouter.self) private var router
    @Binding var customerViewModel: CustomerViewModel
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if customerViewModel.customerList.count == 0 {
                    CustomerEmptyView()
                } else {
                    List {
                        ForEach(customerViewModel.customerList) { customer in
                            if let customerCic = customer.customerCic {
                                NavigationButton(push: .customerHistory(customerCic: customerCic)) {
                                    CustomerCardView(
                                        imageUrl: customer.imageUrl,
                                        mainText: customer.mainText,
                                        mainIndicatorPrefix: "S/. ",
                                        mainIndicator: customer.totalDebt.solesString,
                                        mainIndicatorAlert: customer.isCreditLimit,
                                        secondaryIndicatorSuffix: customer.secondaryIndicatorSuffix,
                                        secondaryIndicator: customer.secondaryIndicator,
                                        secondaryIndicatorAlert: customer.isDateLimit
                                    )
                                    .contextMenu {
                                        NavigationButton(push: .editCustomer(customerCic: customerCic)) {
                                            Text("Editar cliente")
                                        }
                                        NavigationButton(push: .payCustomerTotalDebd(customerCic: customerCic)) {
                                            Text("Pagar deuda")
                                        }
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                                .listRowBackground(Color.background)
                            }
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .listStyle(PlainListStyle())
                }
            }
        }
    }
}
