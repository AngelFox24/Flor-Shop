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
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var addCustomerViewModel: AddCustomerViewModel
    @EnvironmentObject var navManager: NavManager
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingErrorAlert = false
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
                    if addCustomerViewModel.addCustomer() {
                        print("Se agrego un cliente exitosamente")
                        //TODO: Cambiar esta funcion al repositorio
                        customerViewModel.releaseResources()
                        addCustomerViewModel.resetValuesFields()
                        playSound(named: "Success1")
                        navManager.goToBack()
                    } else {
                        addCustomerViewModel.fieldsTrue()
                        playSound(named: "Fail1")
                        print("No se pudo agregar correctamente")
                        showingErrorAlert = true
                    }
                }, label: {
                    CustomButton1(text: "Guardar")
                })
                .alert(addCustomerViewModel.fieldsAddCustomer.errorBD, isPresented: $showingErrorAlert, actions: {})
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

struct AddCustomerTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        AddCustomerTopBar()
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.addCustomerViewModel)
    }
}
