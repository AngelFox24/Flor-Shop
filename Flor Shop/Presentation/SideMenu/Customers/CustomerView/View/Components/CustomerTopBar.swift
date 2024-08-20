//
//  CustomerTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 11/10/23.
//

import SwiftUI

struct CustomerTopBar: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var viewStates: ViewStates
    var backButton: Bool = false
    var body: some View {
        VStack {
            HStack(spacing: 10, content: {
                if backButton {
                    Button(action: {
                        navManager.goToBack()
                    }, label: {
                        CustomButton3(simbol: "chevron.backward")
                    })
                } else {
                    Button(action: {
                        withAnimation(.spring()){
                            viewStates.isShowMenu.toggle()
                        }
                    }, label: {
                        HStack {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                        }
                        .background(Color("colorlaunchbackground"))
                        .cornerRadius(10)
                        .frame(width: 40, height: 40)
                    })
                }
                CustomSearchField(text: $customerViewModel.searchWord)
                Menu {
                    Section("Ordenamiento") {
                        ForEach(CustomerOrder.allValues, id: \.self) { orden in
                            Button {
                                customerViewModel.order = orden
                            } label: {
                                Label(orden.longDescription, systemImage: customerViewModel.order == orden ? "checkmark" : "")
                            }
                        }
                    }
                    Section("Filtros") {
                        ForEach(CustomerFilterAttributes.allValues, id: \.self) { filter in
                            Button {
                                customerViewModel.filter = filter
                            } label: {
                                Label(filter.description, systemImage: customerViewModel.filter == filter ? "checkmark" : "")
                            }
                        }
                    }
                } label: {
                    Button(action: {}, label: {
                        CustomButton3(simbol: "slider.horizontal.3")
                    })
                }
                .onChange(of: customerViewModel.order, perform: { item in
                    customerViewModel.fetchListCustomer()
                })
                .onChange(of: customerViewModel.filter, perform: { item in
                    customerViewModel.fetchListCustomer()
                })
            })
            .padding(.horizontal, 10)
        }
        .padding(.bottom, 9)
        .background(Color("color_primary"))
    }
    func setOrder(order: CustomerOrder) {
        customerViewModel.setOrder(order: order)
    }
    func setFilter(filter: CustomerFilterAttributes) {
        customerViewModel.setFilter(filter: filter)
        print("Se presiono setFilter")
    }
}
//CustomerSearchTopBar
struct CustomerTopBarPopUp: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @State private var selectedOrder: CustomerOrder = .nameAsc
    @State private var selectedFilter: CustomerFilterAttributes = .allCustomers
    let menuOrders: [CustomerOrder] = CustomerOrder.allValues
    let menuFilters: [CustomerFilterAttributes] = CustomerFilterAttributes.allValues
    @State private var seach: String = ""
    var body: some View {
        VStack {
            HStack(spacing: 10, content: {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("color_accent"))
                        .font(.custom("Artifika-Regular", size: 16))
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                    // TODO: Implementar el focus, al pulsar no siempre se abre el teclado
                    TextField("Buscar Cliente", text: $seach)
                        .padding(.vertical, 10)
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color("color_primary"))
                        .submitLabel(.search)
                        .disableAutocorrection(true)
                    Button(action: {
                        customerViewModel.searchWord = ""
                    }, label: {
                        Image(systemName: "x.circle")
                            .foregroundColor(Color("color_accent"))
                            .font(.custom("Artifika-Regular", size: 16))
                            .padding(.vertical, 10)
                            .padding(.trailing, 10)
                    })
                }
                .background(.white)
                .cornerRadius(20.0)
                Menu {
                    Picker("", selection: $selectedOrder) {
                        ForEach(menuOrders, id: \.self) {
                            Text($0.longDescription)
                        }
                    }
                    Divider()
                    Picker("", selection: $selectedFilter) {
                        ForEach(menuFilters, id: \.self) {
                            Text($0.description)
                        }
                    }
                } label: {
                    Button(action: {}, label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 22))
                            .foregroundColor(Color("color_accent"))
                    })
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(15.0)
                }
                .onChange(of: customerViewModel.order, perform: { item in
                    customerViewModel.fetchListCustomer()
                })
                .onChange(of: customerViewModel.filter, perform: { item in
                    customerViewModel.fetchListCustomer()
                })
            })
            .padding(.horizontal, 10)
        }
        .padding(.bottom, 9)
        .background(Color("color_primary"))
    }
    func setOrder(order: CustomerOrder) {
        customerViewModel.setOrder(order: order)
    }
    func setFilter(filter: CustomerFilterAttributes) {
        customerViewModel.setFilter(filter: filter)
        print("Se presiono setFilter")
    }
}
/*
struct CustomerTopBar_Previews: PreviewProvider {
    let customerManager = LocalCustomerManager(mainContext: CoreDataProvider.shared.viewContext)
    let customerRepository = CustomerRepositoryImpl(manager: customerManager)
    let customerViewModel = CustomerViewModel(customerRepository: customerRepository)
    let navManager = NavManager()
    static var previews: some View {
        CustomerTopBar(showMenu: .constant(false))
            .environmentObject(customerViewModel)
            .environmentObject(navManager)
    }
}
*/
