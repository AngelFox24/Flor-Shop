import SwiftUI

struct CustomerViewParameters: Hashable {
    let backButton: Bool
    let forSelectCustomer: Bool
    init(backButton: Bool = false, forSelectCustomer: Bool = false) {
        self.backButton = backButton
        self.forSelectCustomer = forSelectCustomer
    }
}

struct CustomersView: View {
    @Environment(Router.self) private var router
    @EnvironmentObject var customerViewModel: CustomerViewModel
    let parameters: CustomerViewParameters
    init(parameters: CustomerViewParameters = CustomerViewParameters()) {
        self.parameters = parameters
    }
    var body: some View {
        ZStack {
            if !router.showMenu {
                VStack(spacing: 0, content: {
                    Color("color_primary")
                    Color("color_background")
                })
                .ignoresSafeArea()
            }
            VStack(spacing: 0) {
                CustomerTopBar(backButton: parameters.backButton)
                CustomerListController(forSelectCustomer: parameters.forSelectCustomer)
            }
            .background(Color("color_primary"))
            .cornerRadius(router.showMenu ? 35 : 0)
            .padding(.top, router.showMenu ? 0 : 1)
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

struct CustomersView_Previews: PreviewProvider {
    static var previews: some View {
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        CustomersView(parameters: CustomerViewParameters(backButton: false, forSelectCustomer: false))
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.addCustomerViewModel)
            .environmentObject(dependencies.customerHistoryViewModel)
            .environmentObject(dependencies.cartViewModel)
    }
}

struct CustomerListController: View {
    @Environment(Router.self) private var router
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var addCustomerViewModel: AddCustomerViewModel
    @EnvironmentObject var customerHistoryViewModel: CustomerHistoryViewModel
    var forSelectCustomer: Bool = false
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
                                secondaryIndicatorSuffix: customer.isDateLimitActive ? (" " + String(customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month))) : nil,
                                secondaryIndicator: customer.isDateLimitActive ? String(customer.dateLimit.getDateComponent(dateComponent: .day)) : nil,
                                secondaryIndicatorAlert: customer.isDateLimit, size: 80
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
                            .onTapGesture {
                                if forSelectCustomer {
                                    cartViewModel.customerInCar = customer
                                    router.goBack()
                                } else {
                                    customerHistoryViewModel.setCustomerInContext(customer: customer)
//                                    navManager.goToCustomerHistoryView()
                                }
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
                    Button(action: {
                        Task {
                            await addCustomerViewModel.releaseResources()
//                            navManager.goToAddCustomerView()
                        }
                    }, label: {
                        CustomButton4(simbol: "plus")
                    })
                })
                .padding(.trailing, 15)
                .padding(.bottom, 15)
            })
        }
    }
}
