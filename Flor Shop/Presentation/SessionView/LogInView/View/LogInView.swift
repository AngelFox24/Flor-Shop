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
    @ObservedObject var logInFields: LogInFields
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var errorState: ErrorState
    @EnvironmentObject var viewStates: ViewStates
    @FocusState var currentFocusField: AllFocusFields?
    @State private var audioPlayer: AVAudioPlayer?
    @Binding var sesConfig: SessionConfig?
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
                                CustomTextField(title: "Usuario o Correo" ,value: $logInFields.userOrEmail, edited: $logInFields.userOrEmailEdited, keyboardType: .default)
                                if logInFields.userOrEmailError != "" {
                                    ErrorMessageText(message: logInFields.userOrEmailError)
                                    //.padding(.top, 18)
                                }
                            }
                            VStack {
                                CustomTextField(title: "Contraseña" ,value: $logInFields.password, edited: $logInFields.passwordEdited, keyboardType: .default)
                                if logInFields.passwordError != "" {
                                    ErrorMessageText(message: logInFields.passwordError)
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
                                    if logInFields.errorLogIn != "" {
                                        ErrorMessageText(message: logInFields.errorLogIn)
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
            viewStates.isLoading = true
            do {
                print("Se logeara desde Remote")
                self.sesConfig = try await logInViewModel.logIn()
                print("Log In Correcto")
                playSound(named: "Success1")
                await MainActor.run {
                    logInViewModel.logInStatus = .success
                }
            } catch {
                await MainActor.run {
                    errorState.processError(error: error)
                }
                playSound(named: "Fail1")
            }
            viewStates.isLoading = false
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
    @State var field = LogInFields()
    @State var sesConfig: SessionConfig? = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
    var body: some View {
        LogInView(logInFields: field, sesConfig: $sesConfig)
            .environmentObject(nor.logInViewModel)
            .environmentObject(nor.viewStates)
            .environmentObject(nor.navManager)
            .environmentObject(nor.errorState)
    }
}
#Preview {
    LogInView_Previews()
}
