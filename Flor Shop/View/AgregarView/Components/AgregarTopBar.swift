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
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @Binding var editedFields: AgregarViewModel
    @Binding var buttonPress: Bool
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack {
            // El boton de Limpiar tiene un bug por lo que no pasa a prod
            /*
             Button(action: {
             editedFields.resetValuesFields()
             productsCoreDataViewModel.setDefaultProduct()
             }) {
             CustomButton2(text: "Limpiar")
             }
             */
            Spacer()
            Button(action: {
                if productsCoreDataViewModel.addProduct() {
                    print("Se agrego un producto exitosamente")
                    carritoCoreDataViewModel.updateCartTotal()
                    editedFields.resetValuesFields()
                    playSound(named: "Success1")
                } else {
                    buttonPress = true
                    editedFields.editedFields.imageURLError = "lol"
                    editedFields.fieldsTrue()
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
        AgregarTopBar(editedFields: .constant(AgregarViewModel()), buttonPress: .constant(false))
    }
}
