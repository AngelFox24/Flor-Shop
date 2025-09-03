import SwiftUI

struct CustomerSelectionView: View {
    @Environment(FlorShopRouter.self) private var router
    @State var customerViewModel: CustomerViewModel
    init(ses: SessionContainer) {
        self.customerViewModel = CustomerViewModelFactory.getCustomerViewModelFactory(sessionContainer: ses)
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomerSelectionTopBar(customerViewModel: $customerViewModel) {
                    router.back()
                }
                CustomerSelectionListController(customerViewModel: $customerViewModel) {
                    router.back()
                }
            }
            .background(Color("color_primary"))
            .padding(.top, 1)
            .onAppear {
                customerViewModel.lazyFetchList()
            }
            .onDisappear {
                customerViewModel.releaseResources()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CustomerSelectionView(ses: SessionContainer.preview)
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
                                imageUrl: customer.image,
                                topStatusColor: nil,
                                topStatus: nil,
                                mainText: customer.name + " " + customer.lastName,
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: String(format: "%.2f", customer.totalDebt.soles),
                                mainIndicatorAlert: customer.isCreditLimit,
                                secondaryIndicatorSuffix: customer.isDateLimitActive ? (
                                    " " + String(
                                        customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month)
                                    )
                                ) : nil,
                                secondaryIndicator: customer.isDateLimitActive ? String(customer.dateLimit.getDateComponent(dateComponent: .day)) : nil,
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
            .background(Color("color_background"))
            VStack(spacing: 5, content: {
                Spacer()
                HStack(content: {
                    Spacer()
                    NavigationButton(push: .addCustomer) {
                        CustomButton4(simbol: "plus")
                    }
                })
                .padding(.trailing, 15)
                .padding(.bottom, 15)
            })
        }
    }
}
