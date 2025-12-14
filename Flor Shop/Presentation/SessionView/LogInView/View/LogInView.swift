import SwiftUI
import FlorShopDTOs
import AVFoundation

struct LogInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionManager.self) var sessionManager
    @State var logInViewModel = LogInViewModel()
    @State private var audioPlayer: AVAudioPlayer? = nil
    var body: some View {
        ZStack {
            Color.primary
                .ignoresSafeArea()
            VStack(
                content: {
                    HStack(content: {
                        BackButton {
                            dismiss()
                        }
                        Spacer()
                        Text("Iniciar Sesión")
                            .font(.custom("Artifika-Regular", size: 25))
                        Spacer()
                        Spacer()
                            .frame(width: 40, height: 40)
                    })
                    .padding(.horizontal, 15)
                    ScrollView {
                        VStack(spacing: 30) {
                            VStack(spacing: 30) {
                                Button(action: {}, label: {
                                    CustomButton2(text: "Continuar con Google", backgroudColor: Color("color_secondary"), minWidthC: 250)
                                        .foregroundColor(Color(.black))
                                })
                                Button(action: {}, label: {
                                    CustomButton2(text: "Continuar con Apple", backgroudColor: Color("color_secondary"), minWidthC: 250)
                                        .foregroundColor(Color(.black))
                                })
                            }
                            .padding(.top, 30)
                            Spacer()
                        }
                        .padding(.top, 30)
                    }
                    .padding(.top, 1)//Resuelve el problema del desvanecimiento en el navigation back button
                })
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    private func logIn(provider: AuthProvider, token: String) {
        Task {
            do {
                print("Se logeara desde Remote")
                try await sessionManager.login(provider: provider, token: token)
                print("Log In Correcto")
                playSound(named: "Success1")
            } catch {
//                router.presentAlert(.error(error.localizedDescription))
                playSound(named: "Fail1")
            }
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
#Preview {
    LogInView()
}
