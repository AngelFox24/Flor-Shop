//
//  CarritoTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CartTopBar: View {
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @EnvironmentObject var ventasCoreDataViewModel: SalesViewModel
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    var body: some View {
        HStack{
            HStack {
                Text(String("S/. "))
                    .font(.custom("text_font_1", size: 15))
                Text(String(carritoCoreDataViewModel.cartCoreData!.total))
                    .font(.custom("text_font_1", size: 25))
            }
            Spacer()
            Button(action: {
                //Reducimos stock
                print ("Se se va a proceder a reducir el stock en CarritoTopBar")
                if productsCoreDataViewModel.reduceStock(){
                    print ("Se ha reducido el stock en CarritoTopBar exitosamente")
                    //Luego de haber reducido el stock de forma exitosa vendemos
                    if ventasCoreDataViewModel.registerSale(){
                        print ("Se procede a vaciar el carrito")
                        carritoCoreDataViewModel.emptyCart()
                    }else{
                        print("Todo esta mal renuncia xd")
                    }
                }else{
                    print("No hay sufiente stock")
                }
            })
            {
                CustomButton1(text: "Vender")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom,8)
        .padding(.horizontal,40)
        .background(Color("color_primary"))
    }
}

struct CartTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let carManager = LocalCarManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let carRepository = CarRepositoryImpl(manager: carManager)
        let saleManager = LocalSaleManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let salesRepository = SaleRepositoryImpl(manager: saleManager)
        CartTopBar()
            .environmentObject(CartViewModel(carRepository: carRepository))
            .environmentObject(SalesViewModel(saleRepository: salesRepository))
    }
}
