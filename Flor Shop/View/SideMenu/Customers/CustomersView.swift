//
//  CustomersView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 2/10/23.
//

import SwiftUI

struct CustomersView: View {
    @Binding var showMenu: Bool
    @EnvironmentObject var customerViewModel: CustomerViewModel
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CustomerTopBar(showMenu: $showMenu)
                CustomerListController()
            }
            .onAppear {
                customerViewModel.lazyFetchList()
            }
        }
    }
}

struct CustomerViewPopUp: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @Binding var customerInContext: Customer?
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CustomerTopBarPopUp()
                CustomerListControllerOfPopUp(customerInContext: $customerInContext)
            }
            .onAppear {
                customerViewModel.lazyFetchList()
            }
        }
    }
}

struct CustomersView_Previews: PreviewProvider {
    static var previews: some View {
        let customerManager = LocalCustomerManager(mainContext: CoreDataProvider.shared.viewContext)
        let customerRepository = CustomerRepositoryImpl(manager: customerManager)
        let customerViewModel = CustomerViewModel(customerRepository: customerRepository)
        @State var customerInContext: Customer?
        @State var showMenu: Bool = false
        CustomerViewPopUp(customerInContext: $customerInContext)
            .environmentObject(customerViewModel)
    }
}

struct CustomerListController: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    var body: some View {
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
                        CardViewTipe2(image: customer.image, mainText: customer.name + " " + customer.lastName, mainIndicatorPrefix: "S/. ", mainIndicator: String(customer.totalDebt), mainIndicatorAlert: false, secondaryIndicatorSuffix: " " + customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month), secondaryIndicator: String(customer.dateLimit.getDateComponent(dateComponent: .day)), secondaryIndicatorAlert: false, size: 80)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .padding(.horizontal, 10)
        .background(Color("color_background"))
    }
}

struct CustomerListControllerOfPopUp: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @Binding var customerInContext: Customer?
    var body: some View {
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
                        CardViewTipe2(image: customer.image, mainText: customer.name + " " + customer.lastName, mainIndicatorPrefix: "S/. ", mainIndicator: String(customer.totalDebt), mainIndicatorAlert: false, secondaryIndicatorSuffix: " " + customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month), secondaryIndicator: String(customer.dateLimit.getDateComponent(dateComponent: .day)), secondaryIndicatorAlert: false, size: 80)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
                            .onTapGesture {
                                customerInContext = customer
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .padding(.horizontal, 10)
        .background(Color("color_background"))
    }
}
