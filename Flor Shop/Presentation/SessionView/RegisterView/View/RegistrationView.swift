import SwiftUI
import FlorShopDTOs

struct RegistrationView: View {
    @Environment(SessionManager.self) var sessionManager
    @Environment(OverlayViewModel.self) var overlayViewModel
    @Binding var path: [SessionRoutes]
    @State var viewModel: RegistrationViewModel
    let provider: AuthProvider
    let token: String
    init(provider: AuthProvider, token: String, path: Binding<[SessionRoutes]>) {
        self.viewModel = RegistrationViewModelFactory.getViewModel()
        self.provider = provider
        self.token = token
        self._path = path
    }
    var body: some View {
        RegistrationFieldsView(viewModel: $viewModel)
            .background(Color.background)
            .navigationTitle("Registrar compañía")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                RegistrationToolbar(action: registerUser)
            }
    }
    func registerUser() {
        let loadingId = self.overlayViewModel.showLoading(origin: "[RegistrationView]")
        Task {
            do {
                let registerStuff = try await viewModel.registerUser(authProvider: self.provider, token: self.token)
                try await self.sessionManager.register(registerStuff: registerStuff)
                self.overlayViewModel.endLoading(id: loadingId, origin: "[RegistrationView]")
            } catch {
                print("[RegistrationView] Ha ocurrido un error: \(error)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al registrar la compañía.",
                    primary: ConfirmAction(
                        title: "Aceptar",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId, origin: "[RegistrationView]")
                        }
                    )
                )
            }
        }
    }
}

struct RegistrationFieldsView: View {
    @Binding var viewModel: RegistrationViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 40){
                HStack {
                    VStack {
                        CustomTextField(title: "Nombre de la Tienda", value: $viewModel.registrationFields.companyName, edited: $viewModel.registrationFields.companyNameEdited)
                        if viewModel.registrationFields.companyNameError != "" {
                            ErrorMessageText(message: viewModel.registrationFields.companyNameError)
                            //.padding(.top, 18)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

//#Preview {
//    RegistrationView()
//}
