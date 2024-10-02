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
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var salesViewModel: SalesViewModel
    @EnvironmentObject var errorState: ErrorState
    @EnvironmentObject var navManager: NavManager
    @Binding var loading: Bool
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
                Button(action: registerSale) {
                    CustomButton1(text: "Finalizar")
                }
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
    func registerSale() {
        Task {
            loading = true
            do {
                guard let cart = cartViewModel.cartCoreData else {
                    throw LocalStorageError.entityNotFound("No se encontro carrito configurado en viewModel")
                }
                try await salesViewModel.registerSale(cart: cart, customerId: cartViewModel.customerInCar?.id, paymentType: cartViewModel.paymentType)
                cartViewModel.releaseResources()
                try await cartViewModel.emptyCart()
                cartViewModel.releaseCustomer()
                await cartViewModel.lazyFetchCart()
                navManager.goToBack()
                playSound(named: "Success1")
            } catch {
                await errorState.processError(error: error)
                playSound(named: "Fail1")
            }
            loading = false
        }
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
        let sesConfig = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: sesConfig)
        @State var loading = false
        PaymentTopBar(loading: $loading)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.salesViewModel)
    }
}
