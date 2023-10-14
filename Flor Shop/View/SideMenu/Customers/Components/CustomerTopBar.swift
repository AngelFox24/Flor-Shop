//
//  CustomerTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 11/10/23.
//

import SwiftUI

struct CustomerTopBar: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @State private var selectedOrder: CustomerOrder = .nameAsc
    @State private var selectedFilter: CustomerFilterAttributes = .allCustomers
    let menuOrders: [CustomerOrder] = CustomerOrder.allValues
    let menuFilters: [CustomerFilterAttributes] = CustomerFilterAttributes.allValues
    @State private var seach: String = ""
    @Binding var showMenu: Bool
    var body: some View {
        VStack {
            HStack(spacing: 10, content: {
                Button(action: {
                    withAnimation(.spring()){
                        showMenu.toggle()
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
                        .onSubmit {
                            filtrarProductos(filterWord: seach)
                        }
                        .disableAutocorrection(true)
                    Button(action: {
                        seach = ""
                        selectedOrder = .nameAsc
                        selectedFilter = .allCustomers
                        setOrder(order: selectedOrder)
                        setFilter(filter: selectedFilter)
                        filtrarProductos(filterWord: seach)
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
                .onChange(of: selectedOrder, perform: { item in
                    setOrder(order: item)
                    filtrarProductos(filterWord: seach)
                })
                .onChange(of: selectedFilter, perform: { item in
                    setFilter(filter: item)
                    filtrarProductos(filterWord: seach)
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
    func filtrarProductos(filterWord: String) {
        print("Se presiono Buscar Clientes")
        customerViewModel.filterCustomer(word: filterWord)
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
                        .onSubmit {
                            filtrarProductos(filterWord: seach)
                        }
                        .disableAutocorrection(true)
                    Button(action: {
                        seach = ""
                        selectedOrder = .nameAsc
                        selectedFilter = .allCustomers
                        setOrder(order: selectedOrder)
                        setFilter(filter: selectedFilter)
                        filtrarProductos(filterWord: seach)
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
                .onChange(of: selectedOrder, perform: { item in
                    setOrder(order: item)
                    filtrarProductos(filterWord: seach)
                })
                .onChange(of: selectedFilter, perform: { item in
                    setFilter(filter: item)
                    filtrarProductos(filterWord: seach)
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
    func filtrarProductos(filterWord: String) {
        print("Se presiono Buscar Clientes")
        customerViewModel.filterCustomer(word: filterWord)
    }
}
/*
struct CustomerTopBar_Previews: PreviewProvider {
    let customerManager = LocalCustomerManager(mainContext: CoreDataProvider.shared.viewContext)
    let customerRepository = CustomerRepositoryImpl(manager: customerManager)
    let customerViewModel = CustomerViewModel(customerRepository: customerRepository)
    static var previews: some View {
        CustomerTopBar(showMenu: .constant(false))
            .environmentObject(customerViewModel)
    }
}
*/
