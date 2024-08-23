//
//  LogInView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/08/23.
//

import SwiftUI
import AVFoundation

struct LogInView: View {
    @EnvironmentObject var logInViewModel: LogInViewModel
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var errorState: ErrorState
    @State private var audioPlayer: AVAudioPlayer?
    @Binding var loading: Bool
    var body: some View {
        ZStack {
            Color("color_primary")
                .ignoresSafeArea()
            VStack(content: {
                HStack(content: {
                    Button(action: {
                        navManager.goToBack()
                    }, label: {
                        CustomButton3()
                    })
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
                                CustomTextField(title: "Usuario o Correo" ,value: $logInViewModel.logInFields.userOrEmail, edited: $logInViewModel.logInFields.userOrEmailEdited, keyboardType: .default)
                                if logInViewModel.logInFields.userOrEmailError != "" {
                                    ErrorMessageText(message: logInViewModel.logInFields.userOrEmailError)
                                    //.padding(.top, 18)
                                }
                            }
                            VStack {
                                CustomTextField(title: "Contraseña" ,value: $logInViewModel.logInFields.password, edited: $logInViewModel.logInFields.passwordEdited, keyboardType: .default)
                                if logInViewModel.logInFields.passwordError != "" {
                                    ErrorMessageText(message: logInViewModel.logInFields.passwordError)
                                    //.padding(.top, 18)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        VStack(spacing: 30) {
                            Button(action: {
                                logIn()
                            }, label: {
                                VStack {
                                    CustomButton2(text: "Ingresar", backgroudColor: Color("color_accent"), minWidthC: 250)
                                        .foregroundColor(Color(.black))
                                    if logInViewModel.logInFields.errorLogIn != "" {
                                        ErrorMessageText(message: logInViewModel.logInFields.errorLogIn)
                                    }
                                }
                            })
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
            loading = true
            do {
                print("Se logeara desde Remote")
                let ses = try await logInViewModel.logIn()
                print("Log In Correcto")
                playSound(named: "Success1")
                await MainActor.run {
                    self.logInViewModel.businessDependencies = BusinessDependencies(sessionConfig: ses)
                    navManager.popToRoot()
                }
            } catch {
                await MainActor.run {
                    errorState.processError(error: error)
                }
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

struct LogInView_Previews: View {
    let nor = NormalDependencies()
    var body: some View {
        @State var loading = false
        LogInView(loading: $loading)
            .environmentObject(nor.logInViewModel)
            .environmentObject(nor.navManager)
            .environmentObject(nor.errorState)
    }
}
#Preview {
    LogInView_Previews()
}
