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
        .onDisappear {
            customerViewModel.releaseResources()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct CustomersView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        CustomersView(showMenu: .constant(false))
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.navManager)
    }
}

struct CardViewTipe2_2: View {
    var id: UUID?
    var url: String?
    //var topStatusColor: Color?
    //var topStatus: String?
    //var mainText: String
    //var mainIndicatorPrefix: String?
    //var mainIndicator: String
    //var mainIndicatorAlert: Bool
    //var secondaryIndicatorSuffix: String?
    //var secondaryIndicator: String?
    //var secondaryIndicatorAlert: Bool
    let size: CGFloat
    var body: some View {
            CustomAsyncImageView(id: id, urlProducto: url, size: size)
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
                            CustomAsyncImageView(
                                id: customer.image?.id,
                                urlProducto: customer.image?.imageUrl,
                                size: 80
                            )
                            CardViewTipe2_2(
                                id: customer.image?.id,
                                url: customer.image?.imageUrl,
                                //topStatusColor: customer.customerTipe.color,
                                //topStatus: customer.customerTipe.description,
                                //mainText: customer.name + " " + customer.lastName,
                                //mainIndicatorPrefix: "S/. ",
                                //mainIndicator: String(customer.totalDebt),
                                //mainIndicatorAlert: customer.isCreditLimit,
                                //secondaryIndicatorSuffix: customer.isDateLimitActive ? (" " + String(customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month))) : nil,
                                //secondaryIndicator: customer.isDateLimitActive ? String(customer.dateLimit.getDateComponent(dateComponent: .day)) : nil,
                                //secondaryIndicatorAlert: customer.isDateLimit,
                                size: 80
                            )
                            CardViewTipe2(
                                id: customer.image?.id,
                                url: customer.image?.imageUrl,
                                topStatusColor: customer.customerTipe.color,
                                topStatus: customer.customerTipe.description,
                                mainText: customer.name + " " + customer.lastName,
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: String(customer.totalDebt),
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
                                    //addCustomerViewModel.editCustomer(customer: customer)
                                    //navManager.goToAddCustomerView()
                                    customerHistoryViewModel.setCustomerInContext(customer: customer)
                                    navManager.goToCustomerHistoryView()
                                }
                            }
                            .onAppear {
                                let _ = print("\(customer.image?.id)")
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
                        addCustomerViewModel.releaseResources()
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
