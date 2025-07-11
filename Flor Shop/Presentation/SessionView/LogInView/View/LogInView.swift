import SwiftUI
import AVFoundation

struct LogInView: View {
    @Environment(Router.self) private var router
    @Environment(LogInViewModel.self) private var logInViewModel
    @Environment(PersistenceSessionConfig.self) private var sessionConfig
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        @Bindable var logInViewModel = logInViewModel
        ZStack {
            Color("color_primary")
                .ignoresSafeArea()
            VStack(
                content: {
                    HStack(content: {
                        BackButton()
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
                            VStack(spacing: 40){
                                VStack {
                                    CustomTextField(
                                        title: "Usuario o Correo" ,
                                        value: $logInViewModel.userOrEmail,
                                        edited: $logInViewModel.userOrEmailEdited,
                                        keyboardType: .default
                                    )
                                    if logInViewModel.userOrEmailError != "" {
                                        ErrorMessageText(message: logInViewModel.userOrEmailError)
                                        //.padding(.top, 18)
                                    }
                                }
                                VStack {
                                    CustomTextField(
                                        title: "Contraseña" ,
                                        value: $logInViewModel.password,
                                        edited: $logInViewModel.passwordEdited,
                                        keyboardType: .default
                                    )
                                    if logInViewModel.passwordError != "" {
                                        ErrorMessageText(message: logInViewModel.passwordError)
                                        //.padding(.top, 18)
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                            VStack(spacing: 30) {
                                Button(action: logIn) {
                                    VStack {
                                        CustomButton2(text: "Ingresar", backgroudColor: Color("color_accent"), minWidthC: 250)
                                            .foregroundColor(Color(.black))
                                        if logInViewModel.errorLogIn != "" {
                                            ErrorMessageText(message: logInViewModel.errorLogIn)
                                        }
                                    }
                                }
                                Color(.gray)
                                    .frame(width: 280, height: 2)
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
    private func logIn() {
        Task {
            router.isLoanding = true
            do {
                print("Se logeara desde Remote")
                let ses = try await logInViewModel.logIn()
                print("Log In Correcto")
                playSound(named: "Success1")
                await MainActor.run {
                    self.sessionConfig.fromSession(ses)
//                    self.logInViewModel.businessDependencies = BusinessDependencies(sessionConfig: ses)
//                    self.logInViewModel.businessDependencies?.webSocket.connect()
                    router.popToRoot()
                }
            } catch {
                router.presentAlert(.error(error.localizedDescription))
                playSound(named: "Fail1")
                router.isLoanding = false
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
//
//struct LogInView_Previews: View {
//    @State private var router = Router()
//    let nor = NormalDependencies()
//    var body: some View {
//        LogInView()
//            .environment(nor.logInViewModel)
//            .environment(router)
//    }
//}
#Preview {
    @Previewable @State var router = Router()
    let nor = NormalDependencies()
    LogInView()
        .environment(nor.logInViewModel)
        .environment(router)
}
