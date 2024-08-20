//
//  AddCustomerTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 14/10/23.
//

import SwiftUI

import CoreData
import AVFoundation

struct AddCustomerTopBar: View {
    @EnvironmentObject var errorState: ErrorState
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var addCustomerViewModel: AddCustomerViewModel
    @EnvironmentObject var customerHistoryViewModel: CustomerHistoryViewModel
    @EnvironmentObject var navManager: NavManager
    @State private var audioPlayer: AVAudioPlayer?
    @Binding var loading: Bool
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
                    addCustomer()
                }, label: {
                    CustomButton1(text: "Guardar")
                })
//                .alert(addCustomerViewModel.fieldsAddCustomer.errorBD, isPresented: $showingErrorAlert, actions: {})
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
    func addCustomer() {
        Task {
            loading = true
            do {
                try await addCustomerViewModel.addCustomer()
                playSound(named: "Success1")
                customerHistoryViewModel.updateData()
                navManager.goToBack()
            } catch {
                await MainActor.run {
                    errorState.processError(error: error)
                }
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

struct AddCustomerTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        @State var loading: Bool = false
        AddCustomerTopBar(loading: $loading)
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.addCustomerViewModel)
    }
}
