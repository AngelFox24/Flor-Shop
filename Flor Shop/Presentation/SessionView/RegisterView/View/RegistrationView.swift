import SwiftUI
import AVFoundation

struct RegistrationView: View {
    @Environment(Router.self) private var router
    @Environment(LogInViewModel.self) var logInViewModel
    @Environment(RegistrationViewModel.self) var registrationViewModel
    @Environment(PersistenceSessionConfig.self) private var sessionConfig
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        @Bindable var registrationViewModel = registrationViewModel
        ZStack {
            Color("color_primary")
                .ignoresSafeArea()
            VStack(content: {
                HStack(content: {
                    BackButton()
                    Spacer()
                    Text("Crea una Cuenta")
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
                                CustomTextField(title: "Correo" ,value: $registrationViewModel.registrationFields.email, edited: $registrationViewModel.registrationFields.emailEdited)
                                if registrationViewModel.registrationFields.emailError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.emailError)
                                    //.padding(.top, 8)
                                }
                            }
                            VStack {
                                CustomTextField(title: "Usuario" ,value: $registrationViewModel.registrationFields.user, edited: $registrationViewModel.registrationFields.userEdited)
                                if registrationViewModel.registrationFields.userError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.userError)
                                    //.padding(.top, 18)
                                }
                            }
                            VStack {
                                CustomTextField(title: "Contraseña" ,value: $registrationViewModel.registrationFields.password, edited: $registrationViewModel.registrationFields.passwordEdited)
                                if registrationViewModel.registrationFields.passwordError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.passwordError)
                                    //.padding(.top, 18)
                                }
                            }
                            HStack {
                                VStack {
                                    CustomTextField(title: "Nombre de la Tienda" ,value: $registrationViewModel.registrationFields.companyName, edited: $registrationViewModel.registrationFields.companyNameEdited)
                                    if registrationViewModel.registrationFields.companyNameError != "" {
                                        ErrorMessageText(message: registrationViewModel.registrationFields.companyNameError)
                                        //.padding(.top, 18)
                                    }
                                }
                            }
                            VStack {
                                CustomTextField(title: "Nombre del Dueño" ,value: $registrationViewModel.registrationFields.managerName, edited: $registrationViewModel.registrationFields.managerNameEdited)
                                if registrationViewModel.registrationFields.managerNameError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.managerNameError)
                                    //.padding(.top, 18)
                                }
                            }
                            VStack {
                                CustomTextField(title: "Apellidos del Dueño" ,value: $registrationViewModel.registrationFields.managerLastName, edited: $registrationViewModel.registrationFields.managerLastNameEdited)
                                if registrationViewModel.registrationFields.managerLastNameError != "" {
                                    ErrorMessageText(message: registrationViewModel.registrationFields.managerLastNameError)
                                    //.padding(.top, 18)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        Button(action: registerUser) {
                            CustomButton2(text: "Registrar", backgroudColor: Color("color_accent"), minWidthC: 250)
                                .foregroundColor(Color(.black))
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.top, 1)
            })
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    func registerUser() {
        Task {
            
            router.isLoading = true
            do {
                let ses = try await registrationViewModel.registerUser()
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
                router.isLoading = false
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

#Preview {
    @Previewable @State var router = Router()
    let nor = NormalDependencies()
    RegistrationView()
        .environment(nor.logInViewModel)
        .environment(nor.registrationViewModel)
        .environment(router)
}
