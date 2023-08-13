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
    @EnvironmentObject var ventasCoreDataViewModel: SalesViewModel
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack {
            HStack {
                Text(String("S/. "))
                    .foregroundColor(.black)
                    .font(.custom("Artifika-Regular", size: 15))
                Text(String(carritoCoreDataViewModel.cartCoreData!.total))
                    .foregroundColor(.black)
                    .font(.custom("Artifika-Regular", size: 25))
            }
            Spacer()
            Button(action: {
                // Reducimos stock
                print("Se se va a proceder a reducir el stock en CarritoTopBar")
                if productsCoreDataViewModel.reduceStock() {
                    print("Se ha reducido el stock en CarritoTopBar exitosamente")
                    // Luego de haber reducido el stock de forma exitosa vendemos
                    if ventasCoreDataViewModel.registerSale() {
                        print("Se procede a vaciar el carrito")
                        carritoCoreDataViewModel.emptyCart()
                        playSound(named: "Success1")
                    } else {
                        print("Todo esta mal renuncia xd")
                    }
                } else {
                    print("No hay sufiente stock")
                }
            }, label: {
                CustomButton1(text: "Vender")
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        //.padding(.top, 57)
        .padding(.horizontal, 40)
        .background(Color("color_primary"))
    }
    private func playSound(named fileName: String) {
        var soundURL: URL?
        soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3")
        guard let url = soundURL else {
            print("No se pudo encontrar el archivo de sonido.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("No se pudo reproducir el sonido. Error: \(error.localizedDescription)")
        }
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
