import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FlorShopDTOs
import AVFoundation

struct GoogleSingInButton: View {
    @Environment(OverlayViewModel.self) var overlayViewModel
    @Binding var path: [SessionRoutes]
    @State private var audioPlayer: AVAudioPlayer? = nil
    var body: some View {
        Button(action: handleSignInButton) {
            CustomButton2(text: "Continuar con Google", backgroudColor: Color("color_secondary"), minWidthC: 250)
                .foregroundColor(Color(.black))
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
    private func handleSignInButton() {
        let loadingId = self.overlayViewModel.showLoading()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
          print("There is no active window scene")
          return
        }
        guard let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?
            .rootViewController
        else {
          print("There is no key window or root view controller")
          return
        }
        Task {
            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                guard let token = result.user.idToken?.tokenString else {
                    throw NSError(domain: "No token", code: 0, userInfo: nil)
                }
                await MainActor.run {
                    self.path.append(.companySelection(provider: .google, token: token))
                }
                self.overlayViewModel.endLoading(id: loadingId)
            } catch {
                self.overlayViewModel.showAlert(
                    title: "Alert",
                    message: "No se pudo iniciar sesión con Google. Inténtalo nuevamente.",
                    primary: AlertAction(
                        title: "Ok",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId)
                        }
                    )
                )
            }
        }
    }
}

#Preview {
    WelcomeView()
}
