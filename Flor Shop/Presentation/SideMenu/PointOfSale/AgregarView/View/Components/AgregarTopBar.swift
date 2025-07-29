import SwiftUI
import AVFoundation

struct AgregarTopBar: View {
    @Environment(Router.self) private var router
    @Environment(AgregarViewModel.self) var agregarViewModel
    @Environment(ProductViewModel.self) var productViewModel
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack {
            FlorShopButton()
            Spacer()
            Button(action: saveProduct) {
                CustomButton1(text: "Guardar")
            }
        }
        .padding(.top, router.showMenu ? 15 : 0)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
    private func saveProduct() {
        Task {
            router.isLoading = true
            do {
                try await agregarViewModel.addProduct()
                await productViewModel.releaseResources()
                playSound(named: "Success1")
            } catch {
                router.presentAlert(.error(error.localizedDescription))
                playSound(named: "Fail1")
            }
            router.isLoading = false
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
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        VStack {
            AgregarTopBar()
                .environment(dependencies.agregarViewModel)
            Spacer()
        }
    }
}
