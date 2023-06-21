//
//  CarritoTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CartTopBar: View {
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    @EnvironmentObject var ventasCoreDataViewModel: VentasCoreDataViewModel
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    var body: some View {
        HStack{
            HStack {
                Text(String("S/. "))
                    .font(.custom("text_font_1", size: 15))
                Text(String(carritoCoreDataViewModel.carritoCoreData!.total))
                    .font(.custom("text_font_1", size: 25))
            }
            Spacer()
            Button(action: {
                //Reducimos stock
                print ("Se se va a proceder a reducir el stock en CarritoTopBar")
                if productsCoreDataViewModel.reducirStock(){
                    print ("Se ha reducido el stock en CarritoTopBar exitosamente")
                    //Luego de haber reducido el stock de forma exitosa vendemos
                    if ventasCoreDataViewModel.registrarVenta(){
                        print ("Se procede a vaciar el carrito")
                        carritoCoreDataViewModel.vaciarCarrito()
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

struct CarritoTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let carManager = LocalCarManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let carRepository = CarRepositoryImpl(manager: carManager)
        let saleManager = LocalSaleManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let salesRepository = SaleRepositoryImpl(manager: saleManager)
        CartTopBar()
            .environmentObject(CarritoCoreDataViewModel(carRepository: carRepository))
            .environmentObject(VentasCoreDataViewModel(saleRepository: salesRepository))
    }
}
