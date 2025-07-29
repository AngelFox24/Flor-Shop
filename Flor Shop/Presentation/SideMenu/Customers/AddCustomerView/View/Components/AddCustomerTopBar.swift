import SwiftUI
import AVFoundation

struct AddCustomerTopBar: View {
    @Environment(Router.self) private var router
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var addCustomerViewModel: AddCustomerViewModel
    @EnvironmentObject var customerHistoryViewModel: CustomerHistoryViewModel
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack {
            HStack(content: {
                BackButton()
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
            router.isLoanding = true
            do {
                try await addCustomerViewModel.addCustomer()
                playSound(named: "Success1")
                try customerHistoryViewModel.updateData()
                router.goBack()
            } catch {
                router.presentAlert(.error(error.localizedDescription))
                playSound(named: "Fail1")
            }
            router.isLoanding = false
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
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        AddCustomerTopBar()
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.addCustomerViewModel)
    }
}
