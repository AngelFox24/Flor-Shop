//
//  CarritoTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CarritoTopBar: View {
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    @EnvironmentObject var ventasCoreDataViewModel: VentasCoreDataViewModel
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    var body: some View {
        HStack{
            Text("S/.  " + String(carritoCoreDataViewModel.carritoCoreData!.total))
                .font(.title2)
            Spacer()
            Button(action: {
                //Reducimos stock
                print ("Se se va a proceder a reducir el stock en CarritoTopBar")
                if productsCoreDataViewModel.reducirStock(carritoDeCompras: carritoCoreDataViewModel.carritoCoreData){
                    print ("Se ha reducido el stock en CarritoTopBar exitosamente")
                    //Luego de haber reducido el stock de forma exitosa vendemos
                    if ventasCoreDataViewModel.registrarVenta(){
                        carritoCoreDataViewModel.vaciarCarrito()
                    }else{
                        print("Todo esta mal renuncia xd")
                    }
                }else{
                    print("No hay sufiente stock")
                }
            }) {
                Text("Vender")
                    .font(.title)
                    .foregroundColor(Color("color_background"))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background(Color("color_secondary"))
            .cornerRadius(15.0)
            .font(.title)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom,8)
        .padding(.horizontal,20)
        .background(Color("color_primary"))
    }
}

struct CarritoTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let carManager = LocalCarManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let carRepository = CarRepositoryImpl(manager: carManager)
        let saleManager = LocalSaleManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let salesRepository = SaleRepositoryImpl(manager: saleManager)
        CarritoTopBar()
            .environmentObject(CarritoCoreDataViewModel(carRepository: carRepository))
            .environmentObject(VentasCoreDataViewModel(saleRepository: salesRepository))
    }
}
