import SwiftUI

struct WithSession<Content: View>: View {
    @Environment(SessionContainer.self) private var ses
    let content: (SessionContainer) -> Content

    init(@ViewBuilder content: @escaping (SessionContainer) -> Content) {
        self.content = content
    }

    var body: some View {
        content(ses)
    }
}

struct CustomerSelectionView: View {
    @Environment(FlorShopRouter.self) private var router
    @State var customerViewModel: CustomerViewModel
    init(ses: SessionContainer) {
        self.customerViewModel = CustomerViewModelFactory.getCustomerViewModelFactory(sessionContainer: ses)
    }
    var body: some View {
        CustomerSelectionListController(customerViewModel: $customerViewModel, backAction: router.back)
            .navigationTitle("Clientes")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $customerViewModel.searchText, placement: .toolbar)
            .searchToolbarBehavior(.minimize)
            .toolbar {
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
    CustomerSelectionView(ses: SessionContainer.preview)
        .environment(mainRouter)
}

struct CustomerSelectionListController: View {
    @Binding var customerViewModel: CustomerViewModel
    let backAction: () -> Void
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if customerViewModel.customerList.count == 0 {
                    CustomerEmptyView()
                } else {
                    List {
                        ForEach(customerViewModel.customerList) { customer in
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
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color.background)
                            .onTapGesture {
                                customerViewModel.setCustomerInCart(customer: customer)
                                backAction()
                            }
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .listStyle(PlainListStyle())
                }
            }
            .padding(.horizontal, 10)
            .background(Color.background)
        }
    }
}
