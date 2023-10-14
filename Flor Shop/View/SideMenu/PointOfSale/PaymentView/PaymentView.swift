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
                CardViewTipe2(
                    image: cartViewModel.customerInCar?.image ?? ImageUrl.getDummyImage(),
                    topStatusColor: Color.green,
                    topStatus: "Buen Pagador",
                    mainText: cartViewModel.customerInCar?.name ?? "Deconocido" + " " + (cartViewModel.customerInCar?.lastName ?? "x"),
                    mainIndicatorPrefix: "S/. ",
                    mainIndicator: String(cartViewModel.customerInCar?.totalDebt ?? 0.0),
                    mainIndicatorAlert: false,
                    secondaryIndicatorSuffix: cartViewModel.customerInCar?.dateLimit == nil ? nil : " " + String(cartViewModel.customerInCar?.dateLimit?.getShortNameComponent(dateStringNameComponent: .month) ?? ""),
                    secondaryIndicator: cartViewModel.customerInCar?.dateLimit == nil ? nil : String(cartViewModel.customerInCar?.dateLimit?.getDateComponent(dateComponent: .day) ?? 0),
                    secondaryIndicatorAlert: false, size: 80)
                HStack(content: {
                    Spacer()
                    ForEach(PaymentEnums.allValues, id: \.self, content: { paymentType in
                        CardViewTipe3(icon: paymentType.icon, text: paymentType.icon, enable: cartViewModel.paymentType == paymentType)
                            .onTapGesture {
                                cartViewModel.paymentType = paymentType
                            }
                        Spacer()
                    })
                })
            })
        })
        .padding(.horizontal, 10)
    }
}

struct CardViewTipe3: View {
    var icon: String
    var text: String
    var enable: Bool = false
    var body: some View {
        VStack(spacing: 0, content: {
            Spacer()
            Image(systemName: icon)
                .font(.custom("Artifika-Regular", size: 28))
                .foregroundColor(enable ? Color("color_background") : Color("color_primary"))
            Spacer()
            Text(text)
                .font(.custom("Artifika-Regular", size: 15))
                .foregroundColor(enable ? Color("color_background") : Color("color_primary"))
            Spacer()
        })
        .frame(width: 80, height: 80)
        .background(enable ? Color("color_accent") : Color(.white))
        .cornerRadius(15)
    }
}
