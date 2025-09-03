import SwiftUI

struct CustomersView: View {
    @State var customerViewModel: CustomerViewModel
    @Binding var showMenu: Bool
    init(ses: SessionContainer, showMenu: Binding<Bool>) {
        self.customerViewModel = CustomerViewModelFactory.getCustomerViewModelFactory(sessionContainer: ses)
        self._showMenu = showMenu
    }
    var body: some View {
        ZStack {
            if !showMenu {
                VStack(spacing: 0, content: {
                    Color("color_primary")
                    Color("color_background")
                })
                .ignoresSafeArea()
            }
            VStack(spacing: 0) {
                CustomerTopBar(customerViewModel: $customerViewModel, showMenu: $showMenu)
                CustomerListController(customerViewModel: $customerViewModel)
            }
            .background(Color("color_primary"))
            .cornerRadius(showMenu ? 35 : 0)
            .padding(.top, showMenu ? 0 : 1)
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
    CustomersView(ses: SessionContainer.preview, showMenu: .constant(false))
}

struct CustomerListController: View {
    @Binding var customerViewModel: CustomerViewModel
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
                            NavigationButton(push: .customerHistory(customerId: customer.id)) {
                                CardViewTipe2(
                                    imageUrl: customer.image,
                                    topStatusColor: nil,
                                    topStatus: nil,
                                    mainText: customer.name + " " + customer.lastName,
                                    mainIndicatorPrefix: "S/. ",
                                    mainIndicator: String(format: "%.2f", customer.totalDebt.soles),
                                    mainIndicatorAlert: customer.isCreditLimit,
                                    secondaryIndicatorSuffix: customer.isDateLimitActive ? (" " + String(customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month))) : nil,
                                    secondaryIndicator: customer.isDateLimitActive ? String(customer.dateLimit.getDateComponent(dateComponent: .day)) : nil,
                                    secondaryIndicatorAlert: customer.isDateLimit, size: 80
                                )
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
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
