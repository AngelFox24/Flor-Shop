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
                customerViewModel.lazyFetchList()
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
                    VStack {
                        Image("groundhog_finding")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                        Text("No hay clientes registrados aún.")
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .font(.custom("Artifika-Regular", size: 18))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(customerViewModel.customerList) { customer in
                            CardViewTipe2(
                                imageUrl: customer.imageUrl,
                                topStatusColor: nil,
                                topStatus: nil,
                                mainText: customer.name + " " + (customer.lastName ?? ""),
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: String(format: "%.2f", customer.totalDebt.soles),
                                mainIndicatorAlert: customer.isCreditLimit,
                                secondaryIndicatorSuffix: nil, //TODO: poner en variable calculada
//                                    customer.isDateLimitActive ? (" " + String(customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month))) : nil,
                                secondaryIndicator: nil, //TODO: poner en variable calculada
//                                customer.isDateLimitActive ? String(customer.dateLimit.getDateComponent(dateComponent: .day)) : nil,
                                secondaryIndicatorAlert: customer.isDateLimit,
                                size: 80
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
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
