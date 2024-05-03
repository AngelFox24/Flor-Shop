//
//  PaymentTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 9/10/23.
//

import SwiftUI
import CoreData
import AVFoundation

struct PaymentTopBar: View {
    // TODO: Corregir el calculo del total al actualizar precio en AgregarView
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @EnvironmentObject var ventasCoreDataViewModel: SalesViewModel
    //@EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var navManager: NavManager
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack {
            HStack(content: {
                Button(action: {
                    navManager.goToBack()
                }, label: {
                    CustomButton3()
                })
                Spacer()
                Button(action: {
                    if ventasCoreDataViewModel.registerSale(cart: carritoCoreDataViewModel.cartCoreData, customer: carritoCoreDataViewModel.customerInCar, paymentType: carritoCoreDataViewModel.paymentType) {
                        carritoCoreDataViewModel.releaseResources()
                        carritoCoreDataViewModel.releaseCustomer()
                        playSound(named: "Success1")
                    }
                }, label: {
                    CustomButton1(text: "Finalizar")
                })
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
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
struct PaymentTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        PaymentTopBar()
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.salesViewModel)
    }
}
