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
        /*
        HStack{
            CardViewTipe3(icon: "dollarsign", text: "Efectivo", enable: true)
            CardViewTipe3(icon: "dollarsign", text: "Fiado")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
        */
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
                CardViewTipe2(image: ImageUrl.getDummyImage(), topStatusColor: Color.green, topStatus: "Buen Pagador", mainText: "Mariano Aceña Simón", mainIndicatorPrefix: "S/. ", mainIndicator: "23.00", mainIndicatorAlert: false, secondaryIndicatorSuffix: " u", secondaryIndicator: "9", secondaryIndicatorAlert: false, size: 80)
                HStack(content: {
                    Spacer()
                    CardViewTipe3(icon: "dollarsign", text: "Efectivo", enable: true)
                    Spacer()
                    CardViewTipe3(icon: "list.clipboard", text: "Fiado")
                    Spacer()
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
