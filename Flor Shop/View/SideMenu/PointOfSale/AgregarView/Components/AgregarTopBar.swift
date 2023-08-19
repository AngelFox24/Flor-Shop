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
    @EnvironmentObject var companyViewModel: CompanyViewModel
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack {
            AgregarViewPopoverHelp()
            Spacer()
            Button(action: {
                if agregarViewModel.addProduct(subsidiary: companyViewModel.subsidiary ?? Subsidiary.getDummySubsidiary()) {
                    print("Se agrego un producto exitosamente")
                    //TODO: Cambiar esta funcion al repositorio
                    carritoCoreDataViewModel.updateCartTotal()
                    agregarViewModel.resetValuesFields()
                    playSound(named: "Success1")
                } else {
                    agregarViewModel.fieldsTrue()
                    playSound(named: "Fail1")
                    print("No se pudo agregar correctamente")
                }
            }, label: {
                CustomButton1(text: "Guardar")
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
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

struct AgregarTopBar_Previews: PreviewProvider {
    static var previews: some View {
        AgregarTopBar()
    }
}
