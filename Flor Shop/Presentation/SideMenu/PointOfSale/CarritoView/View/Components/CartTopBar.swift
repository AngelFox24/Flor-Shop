//
//  CarritoTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData
import AVFoundation

struct CartTopBar: View {
    // TODO: Corregir el calculo del total al actualizar precio en AgregarView
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @EnvironmentObject var navManager: NavManager
    @Binding var showMenu: Bool
    var body: some View {
        HStack {
            HStack{
                CustomButton5(showMenu: $showMenu)
                Spacer()
                Button(action: {
                    navManager.goToPaymentView()
                    print("Se presiono cobrar")
                }, label: {
                    HStack(spacing: 5, content: {
                        Text(String("S/. "))
                            .font(.custom("Artifika-Regular", size: 15))
                        let total = carritoCoreDataViewModel.cartCoreData?.total.solesString ?? "0"
                        Text(total)
                            .font(.custom("Artifika-Regular", size: 20))
                    })
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .foregroundColor(Color("color_background"))
                    .background(Color("color_accent"))
                    .cornerRadius(15.0)
                })
                Button(action: {
                    navManager.goToCustomerView()
                }, label: {
                    if let customer = carritoCoreDataViewModel.customerInCar, let image = customer.image {
                        CustomAsyncImageView(imageUrl: image, size: 40)
                            .contextMenu(menuItems: {
                                Button(role: .destructive,action: {
                                    carritoCoreDataViewModel.customerInCar = nil
                                }, label: {
                                    Text("Desvincular Cliente")
                                })
                            })
                    } else {
                        CustomButton3(simbol: "person.crop.circle.badge.plus")
                    }
                })
            }
        }
        .padding(.top, showMenu ? 15 : 0)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
}
struct CartTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        @State var showMenu = false
        CartTopBar(showMenu: $showMenu)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(nor.navManager)
    }
}
