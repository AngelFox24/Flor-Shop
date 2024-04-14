//
//  AgregarTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/06/23.
//

import SwiftUI
import CoreData
import AVFoundation

struct AgregarTopBar: View {
    @EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingErrorAlert = false
    var body: some View {
        HStack {
            AgregarViewPopoverHelp()
            Spacer()
            Button(action: {
                Task {
                    agregarViewModel.isLoading = true
                    if await agregarViewModel.addProduct() {
                        productViewModel.releaseResources()
                        agregarViewModel.resetValuesFields()
                        playSound(named: "Success1")
                    } else {
                        playSound(named: "Fail1")
                        showingErrorAlert = agregarViewModel.errorBD == "" ? false : true
                    }
                    agregarViewModel.isLoading = false
                }
            }, label: {
                CustomButton1(text: "Guardar")
            })
            .alert(agregarViewModel.errorBD, isPresented: $showingErrorAlert, actions: {})
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

struct AgregarTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        AgregarTopBar()
            .environmentObject(dependencies.agregarViewModel)
    }
}
