//
//  CustomerHistoryTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/03/24.
//
import SwiftUI
import CoreData
import AVFoundation

struct CustomerHistoryTopBar: View {
    // TODO: Corregir el calculo del total al actualizar precio en AgregarView
    @EnvironmentObject var customerHistoryViewModel: CustomerHistoryViewModel
    @EnvironmentObject var addCustomerViewModel: AddCustomerViewModel
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
                    print("Se presiono cobrar")
                    if customerHistoryViewModel.payTotalAmount() {
                        customerHistoryViewModel.updateData()
                        playSound(named: "Success1")
                    } else {
                        customerHistoryViewModel.updateData()
                        playSound(named: "Fail1")
                    }
                }, label: {
                    HStack(spacing: 5, content: {
                        Text(String("S/. "))
                            .font(.custom("Artifika-Regular", size: 15))
                        Text(String(format: "%.2f", customerHistoryViewModel.customer?.totalDebt ?? 0.0))
                            .font(.custom("Artifika-Regular", size: 20))
                    })
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .foregroundColor(Color("color_background"))
                    .background(Color("color_accent"))
                    .cornerRadius(15.0)
                })
                if let customer = customerHistoryViewModel.customer {
                    Button(action: {
                        addCustomerViewModel.editCustomer(customer: customer)
                        navManager.goToAddCustomerView()
                    }, label: {
                        CustomAsyncImageView(id: customer.image?.id, urlProducto: customer.image?.imageUrl, size: 40)
                    })
                } else {
                    CustomButton3(simbol: "person.crop.circle.badge.plus")
                }
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
struct CustomerHistoryTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        CustomerHistoryTopBar()
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(dependencies.customerHistoryViewModel)
    }
}
