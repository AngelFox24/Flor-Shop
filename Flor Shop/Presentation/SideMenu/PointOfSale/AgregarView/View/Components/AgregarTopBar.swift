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
    //@EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @Binding var showMenu: Bool
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingErrorAlert = false
    @State private var isPopoverPresented = false
    var body: some View {
        HStack {
            CustomButton5(showMenu: $showMenu)
            Spacer()
            Button(action: {
                Task {
                    agregarViewModel.isLoading = true
                    if await agregarViewModel.addProduct() {
                        agregarViewModel.releaseResources()
                        playSound(named: "Success1")
                    } else {
                        playSound(named: "Fail1")
                        showingErrorAlert = agregarViewModel.agregarFields.errorBD == "" ? false : true
                    }
                    agregarViewModel.isLoading = false
                }
            }, label: {
                CustomButton1(text: "Guardar")
            })
                .alert(agregarViewModel.agregarFields.errorBD, isPresented: $showingErrorAlert, actions: {})
            Menu {
                Button {
                    Task {
                        agregarViewModel.isLoading = true
                        if await agregarViewModel.exportCSV() {
                            //                        agregarViewModel.releaseResources()
                            //                        playSound(named: "Success1")
                        } else {
                            //                        playSound(named: "Fail1")
                            showingErrorAlert = agregarViewModel.agregarFields.errorBD == "" ? false : true
                        }
                        agregarViewModel.isLoading = false
                    }
                } label: {
                    Label("Exportar", systemImage: "square.and.arrow.up")
                }
                Button {
                    Task {
                        agregarViewModel.isLoading = true
                        if await agregarViewModel.importCSV() {
                            //                        agregarViewModel.releaseResources()
                            //                        playSound(named: "Success1")
                        } else {
                            //                        playSound(named: "Fail1")
                            showingErrorAlert = agregarViewModel.agregarFields.errorBD == "" ? false : true
                        }
                        agregarViewModel.isLoading = false
                    }
                } label: {
                    Label("Importar", systemImage: "square.and.arrow.down")
                }
            } label: {
                CustomButton3(simbol: "ellipsis")
                    .rotationEffect(.degrees(90))
            }
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
        VStack {
            AgregarTopBar(showMenu: .constant(false))
                .environmentObject(dependencies.agregarViewModel)
            Spacer()
        }
    }
}
