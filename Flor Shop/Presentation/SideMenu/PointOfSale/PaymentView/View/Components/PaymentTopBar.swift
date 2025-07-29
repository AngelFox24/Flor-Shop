import SwiftUI
import CoreData
import AVFoundation

struct PaymentTopBar: View {
    // TODO: Corregir el calculo del total al actualizar precio en AgregarView
    @Environment(Router.self) private var router
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var salesViewModel: SalesViewModel
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack {
            HStack(content: {
//                Button(action: {
//                    navManager.goToBack()
//                }, label: {
//                    CustomButton3()
//                })
                Spacer()
                Button(action: registerSale) {
                    CustomButton1(text: "Finalizar")
                }
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
    func registerSale() {
        Task {
            router.isLoanding = true
            do {
                guard let cart = cartViewModel.cartCoreData else {
                    throw LocalStorageError.entityNotFound("No se encontro carrito configurado en viewModel")
                }
                try await salesViewModel.registerSale(cart: cart, customerId: cartViewModel.customerInCar?.id, paymentType: cartViewModel.paymentType)
                cartViewModel.releaseResources()
                try await cartViewModel.emptyCart()
                cartViewModel.releaseCustomer()
                await cartViewModel.lazyFetchCart()
                router.goBack()
                playSound(named: "Success1")
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
struct PaymentTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let sesConfig = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: sesConfig)
        PaymentTopBar()
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.salesViewModel)
    }
}
