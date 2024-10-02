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
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @EnvironmentObject var errorState: ErrorState
    @State private var audioPlayer: AVAudioPlayer?
    @Binding var loading: Bool
    @Binding var showMenu: Bool
    var body: some View {
        HStack {
            CustomButton5(showMenu: $showMenu)
            Spacer()
            Button(action: saveProduct) {
                CustomButton1(text: "Guardar")
            }
//            Menu {
//                Button(action: exportProducts) {
//                    Label("Exportar", systemImage: "square.and.arrow.up")
//                }
//                Button(action: importProducts) {
//                    Label("Importar", systemImage: "square.and.arrow.down")
//                }
//            } label: {
//                CustomButton3(simbol: "ellipsis")
//                    .rotationEffect(.degrees(90))
//            }
        }
        .padding(.top, showMenu ? 15 : 0)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
//    private func exportProducts() {
//        Task {
//            loading = true
//            do {
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
//                let currentDate = Date()
//                let formattedDate = dateFormatter.string(from: currentDate)
//                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Products BackUp \(formattedDate).csv")
//                await agregarViewModel.exportCSV(url: tempURL)
//                loading = false
//                showShareSheet(url: tempURL)
//            } catch {
//                await MainActor.run {
//                    errorState.processError(error: error)
//                }
//            }
//            loading = false
//        }
//    }
//    private func importProducts() {
//        Task {
//            loading = true
//            do {
//                await agregarViewModel.importCSV()
//                playSound(named: "Success1")
//            } catch {
//                await MainActor.run {
//                    errorState.processError(error: error)
//                }
//                playSound(named: "Fail1")
//            }
//            loading = false
//        }
//    }
    private func saveProduct() {
        Task {
            loading = true
            do {
//                UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first?.endEditing(true)
                try await agregarViewModel.addProduct()
                playSound(named: "Success1")
            } catch {
                await errorState.processError(error: error)
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

struct AgregarTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        @State var loading = false
        @State var showMenu = false
        VStack {
            AgregarTopBar(loading: $loading, showMenu: $showMenu)
                .environmentObject(dependencies.agregarViewModel)
            Spacer()
        }
    }
}
