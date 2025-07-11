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
    @Environment(Router.self) private var router
    @EnvironmentObject var customerHistoryViewModel: CustomerHistoryViewModel
    @EnvironmentObject var addCustomerViewModel: AddCustomerViewModel
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack {
            HStack(content: {
                BackButton()
                Spacer()
                Button(action: {
                    print("Se presiono cobrar")
                    payDebt()
                }, label: {
                    HStack(spacing: 5, content: {
                        Text(String("S/. "))
                            .font(.custom("Artifika-Regular", size: 15))
                        Text(String(format: "%.2f", customerHistoryViewModel.customer?.totalDebt.soles ?? 0.0))
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
                        editCustomer(customer: customer)
                    }, label: {
                        CustomAsyncImageView(imageUrl: customer.image, size: 40)
                    })
                } else {
                    EmptyProfileButton()
                }
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
    private func payDebt() {
        Task {
            router.isLoanding = true
            do {
                if try await customerHistoryViewModel.payTotalAmount() {
                    try customerHistoryViewModel.updateData()
                    playSound(named: "Success1")
                } else {
                    try customerHistoryViewModel.updateData()
                    playSound(named: "Fail1")
                }
            } catch {
                router.presentAlert(.error(error.localizedDescription))
                playSound(named: "Fail1")
            }
            router.isLoanding = false
        }
    }
    private func editCustomer(customer: Customer) {
        Task {
//            loading = true
            do {
                try await addCustomerViewModel.editCustomer(customer: customer)
//                navManager.goToAddCustomerView()
            } catch {
                router.presentAlert(.error(error.localizedDescription))
                playSound(named: "Fail1")
            }
//            loading = false
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
struct CustomerHistoryTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        CustomerHistoryTopBar()
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(dependencies.customerHistoryViewModel)
    }
}
