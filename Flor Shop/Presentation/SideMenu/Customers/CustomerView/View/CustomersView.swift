//
//  CustomersView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 2/10/23.
//

import SwiftUI

struct CustomersView: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    var backButton: Bool = false
    @Binding var showMenu: Bool
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
                CustomerTopBar(backButton: backButton, showMenu: $showMenu)
                CustomerListController(forSelectCustomer: backButton)
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

struct CustomersView_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        @State var showMenu = false
        CustomersView(showMenu: $showMenu)
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.addCustomerViewModel)
            .environmentObject(dependencies.customerHistoryViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(nor.navManager)
    }
}

struct CustomerListController: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navManager: NavManager
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
                                    navManager.goToBack()
                                } else {
                                    customerHistoryViewModel.setCustomerInContext(customer: customer)
                                    navManager.goToCustomerHistoryView()
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
                        }
                        navManager.goToAddCustomerView()
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
