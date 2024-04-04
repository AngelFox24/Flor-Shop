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
    @EnvironmentObject var navManager: NavManager
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack {
            HStack{
                Button(action: {
                    navManager.goToCustomerView()
                }, label: {
                    if let customer = carritoCoreDataViewModel.customerInCar, let image = customer.image {
                        CustomAsyncImageView(id: image.id, urlProducto: image.imageUrl, size: 40)
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
                Spacer()
                Button(action: {
                    navManager.goToPaymentView()
                    print("Se presiono cobrar")
                }, label: {
                    HStack(spacing: 5, content: {
                        Text(String("S/. "))
                            .font(.custom("Artifika-Regular", size: 15))
                        Text(String(carritoCoreDataViewModel.cartCoreData?.total ?? 0.0))
                            .font(.custom("Artifika-Regular", size: 20))
                    })
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .foregroundColor(Color("color_background"))
                    .background(Color("color_accent"))
                    .cornerRadius(15.0)
                })
            }
            /*
            .navigationDestination(for: NavPathsEnum.self, destination: { view in
                if view == .paymentView {
                    PaymentView()
                } else if view == .customerView {
                    CustomersView(showMenu: .constant(false), backButton: true)
                } else {
                    let _ = print("Nose")
                }
            })
             */
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
struct CartTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        CartTopBar()
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(dependencies.navManager)
    }
}
