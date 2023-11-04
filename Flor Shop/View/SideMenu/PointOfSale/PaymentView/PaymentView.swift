//
//  PaymentView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 9/10/23.
//

import SwiftUI

struct PaymentView: View {
    var body: some View {
        VStack(spacing: 0) {
            PaymentTopBar()
            PaymentsFields()
        }
        .background(Color("color_background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let carManager = LocalCartManager(mainContext: CoreDataProvider.shared.viewContext)
        let carRepository = CarRepositoryImpl(manager: carManager)
        PaymentView()
            .environmentObject(CartViewModel(carRepository: carRepository))
    }
}

struct PaymentsFields: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navManager: NavManager
    var body: some View {
        ScrollView(content: {
            VStack(spacing: 20, content: {
                HStack(content: {
                    Text("S/.")
                        .font(.custom("Artifika-Regular", size: 26))
                        .foregroundColor(.black)
                    Text(String(cartViewModel.cartCoreData?.total ?? 0.0))
                        .font(.custom("Artifika-Regular", size: 55))
                        .foregroundColor(.black)
                })
                .padding(.vertical, 20)
                HStack(content: {
                    Text("Cobrar a:")
                        .font(.custom("Artifika-Regular", size: 20))
                        .foregroundColor(.black)
                    Spacer()
                })
                VStack(content: {
                    if let customer = cartViewModel.customerInCar {
                        CardViewTipe2(
                            image: customer.image,
                            topStatusColor: Color.green,
                            topStatus: "Buen Pagador",
                            mainText: customer.name + " " + customer.lastName,
                            mainIndicatorPrefix: "S/. ",
                            mainIndicator: String(customer.totalDebt),
                            mainIndicatorAlert: false,
                            secondaryIndicatorSuffix: customer.dateLimit == nil ? nil : " " + String(customer.dateLimit?.getShortNameComponent(dateStringNameComponent: .month) ?? ""),
                            secondaryIndicator: customer.dateLimit == nil ? nil : String(customer.dateLimit?.getDateComponent(dateComponent: .day) ?? 0),
                            secondaryIndicatorAlert: false, size: 80)
                        .contextMenu(menuItems: {
                            Button(role: .destructive,action: {
                                cartViewModel.customerInCar = nil
                            }, label: {
                                Text("Desvincular Cliente")
                            })
                        })
                    } else {
                        CardViewPlaceHolder1(size: 80)
                    }
                })
                .onTapGesture {
                    navManager.goToCustomerView()
                }
                HStack(content: {
                    Spacer()
                    ForEach(PaymentEnums.allValues, id: \.self, content: { paymentType in
                        CardViewTipe4(icon: paymentType.icon, text: paymentType.description, enable: cartViewModel.paymentType == paymentType)
                            .onTapGesture {
                                cartViewModel.paymentType = paymentType
                            }
                        Spacer()
                    })
                })
            })
            .navigationDestination(for: NavPathsEnum.self, destination: { view in
                if view == .customerView {
                    CustomersView(showMenu: .constant(false), backButton: true)
                }
            })
        })
        .padding(.horizontal, 10)
    }
}
