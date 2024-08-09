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
    @EnvironmentObject var loadingState: LoadingState
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @EnvironmentObject var errorState: ErrorState
    @EnvironmentObject var viewStates: ViewStates
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingErrorAlert = false
    var body: some View {
        HStack {
            CustomButton5(showMenu: $viewStates.isShowMenu)
            Spacer()
            Button(action: {
                saveProduct()
            }, label: {
                CustomButton1(text: "Guardar")
            })
                .alert(agregarViewModel.agregarFields.errorBD, isPresented: $showingErrorAlert, actions: {})
            Menu {
                Button {
                    print("Cargando")
                    loadingState.isLoading = true
                    print("Creando Directorio")
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Products BackUp \(Date().formatted(date: .abbreviated, time: .omitted)).csv")
                    print("Exportando")
                    agregarViewModel.exportCSV(url: tempURL)
                    print("Mostrando Guardador de Archivos")
                    loadingState.isLoading = false
                    showShareSheet(url: tempURL)
                } label: {
                    Label("Exportar", systemImage: "square.and.arrow.up")
                }
                Button {
                    Task {
                        loadingState.isLoading = true
                        if await agregarViewModel.importCSV() {
                            //                        agregarViewModel.releaseResources()
                            //                        playSound(named: "Success1")
                        } else {
                            //                        playSound(named: "Fail1")
                            showingErrorAlert = agregarViewModel.agregarFields.errorBD == "" ? false : true
                        }
                        loadingState.isLoading = false
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
    private func saveProduct() {
        Task {
            loadingState.isLoading = true
            do {
                try await agregarViewModel.addProduct()
                playSound(named: "Success1")
            } catch {
                await MainActor.run {
                    errorState.processError(error: error)
                }
                playSound(named: "Fail1")
            }
            loadingState.isLoading = false
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

struct AgregarTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        VStack {
            AgregarTopBar()
                .environmentObject(dependencies.agregarViewModel)
                .environmentObject(nor.loadingState)
                .environmentObject(nor.viewStates)
            Spacer()
        }
    }
}
