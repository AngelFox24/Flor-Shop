//
//  CustomersView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 2/10/23.
//

import SwiftUI

struct CustomersView: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @Binding var showMenu: Bool
    var backButton: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            CustomerTopBar(showMenu: $showMenu, backButton: backButton)
            CustomerListController(forSelectCustomer: backButton)
        }
        .onAppear {
            customerViewModel.lazyFetchList()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct CustomersView_Previews: PreviewProvider {
    static var previews: some View {
        let customerManager = LocalCustomerManager(mainContext: CoreDataProvider.shared.viewContext)
        let customerRepository = CustomerRepositoryImpl(manager: customerManager)
        let customerViewModel = CustomerViewModel(customerRepository: customerRepository)
        let navManager = NavManager()
        CustomersView(showMenu: .constant(false))
            .environmentObject(customerViewModel)
            .environmentObject(navManager)
    }
}

struct CustomerListController: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navManager: NavManager
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
                                image: customer.image,
                                mainText: customer.name + " " + customer.lastName,
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: String(customer.totalDebt),
                                mainIndicatorAlert: false,
                                secondaryIndicatorSuffix: customer.dateLimit == nil ? nil : " " + String(customer.dateLimit?.getShortNameComponent(dateStringNameComponent: .month) ?? ""),
                                secondaryIndicator: customer.dateLimit == nil ? nil : String(customer.dateLimit?.getDateComponent(dateComponent: .day) ?? 0),
                                secondaryIndicatorAlert: false, size: 80
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
                            .onTapGesture {
                                if forSelectCustomer {
                                    cartViewModel.customerInCar = customer
                                    navManager.goToBack()
                                }
                            }
                        }
                    }
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
                        navManager.goToAddCustomerView()
                    }, label: {
                        CustomButton4(simbol: "plus")
                    })
                    .navigationDestination(for: NavPathsEnum.self, destination: { view in
                        if view == .addCustomerView {
                            AddCustomerView()
                        }
                    })
                })
                .padding(.trailing, 15)
                .padding(.bottom, 15)
            })
        }
    }
}
