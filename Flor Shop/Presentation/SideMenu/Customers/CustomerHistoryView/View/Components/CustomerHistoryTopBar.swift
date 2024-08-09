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
    @EnvironmentObject var viewStates: ViewStates
    @EnvironmentObject var errorState: ErrorState
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
                    CustomButton3(simbol: "person.crop.circle.badge.plus")
                }
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
    private func editCustomer(customer: Customer) {
        Task {
            viewStates.isLoading = true
            do {
                try await addCustomerViewModel.editCustomer(customer: customer)
                navManager.goToAddCustomerView()
                playSound(named: "Success1")
            } catch {
                await MainActor.run {
                    errorState.processError(error: error)
                }
                playSound(named: "Fail1")
            }
            viewStates.isLoading = false
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
