//
//  CustomersView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 2/10/23.
//

import SwiftUI

struct CustomersView: View {
    @Binding var isKeyboardVisible: Bool
    @Binding var showMenu: Bool
    @EnvironmentObject var customerViewModel: CustomerViewModel
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ProductSearchTopBar(showMenu: $showMenu)
                CustomerListController()
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
        @State var showMenu: Bool = false
        CustomersView(isKeyboardVisible: .constant(false),showMenu: $showMenu)
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
                    CardViewTipe2(image: customer.image, mainText: customer.name + " " + customer.lastName, mainIndicatorPrefix: "S/. ", mainIndicator: String(customer.totalDebt), mainIndicatorAlert: false, secondaryIndicatorSuffix: " " + customDateFormatter(dateIn: customer.dateLimit), secondaryIndicator: Calendar.current.component(.day, from: customer.dateLimit), secondaryIndicatorAlert: false, size: 80)
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

func customDateFormatter(dateIn: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "es_ES") // Establece el idioma español
    dateFormatter.dateFormat = "LLL" // Usa "LLL" para obtener el nombre del mes corto

    return dateFormatter.string(from: dateIn)
}
