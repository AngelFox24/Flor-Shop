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
    @EnvironmentObject var productViewModel: ProductViewModel
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
        }
        .padding(.top, showMenu ? 15 : 0)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
    private func saveProduct() {
        Task {
            loading = true
            do {
//                UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first?.endEditing(true)
                try await agregarViewModel.addProduct()
                await productViewModel.releaseResources()
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
