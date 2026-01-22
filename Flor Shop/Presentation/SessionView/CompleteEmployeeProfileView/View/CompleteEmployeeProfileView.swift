import SwiftUI
import FlorShopDTOs

struct CompleteEmployeeProfileView: View {
    @Environment(OverlayViewModel.self) var overlayViewModel
    @Environment(SessionManager.self) var sessionManager
    @Binding var path: [SessionRoutes]
    @State private var viewModel: CompleteEmployeeProfileViewModel
    let subsidiaryCic: String
    init(subsidiaryCic: String, path: Binding<[SessionRoutes]>) {
        self.viewModel = CompleteEmployeeProfileViewModelFactory.getViewModel()
        self._path = path
        self.subsidiaryCic = subsidiaryCic
    }
    var body: some View {
        CompleteEmployeeProfileListView(viewModel: $viewModel)
            .background(Color.background)
            .navigationTitle("Complete su perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                MainConfirmationToolbar(disabled: false, action: completeProfile)
            }
    }
    private func completeProfile() {
        let loadingId = self.overlayViewModel.showLoading()
        Task {
            do {
                let employee = self.viewModel.getEmployee()
                try await self.sessionManager.completeProfile(employee: employee, subsidiaryCic: subsidiaryCic)
                self.overlayViewModel.endLoading(id: loadingId)
            } catch {
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ocurrio un error al completar el perfil. Intente nuevamente.",
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
    CompleteEmployeeProfileView(subsidiaryCic: UUID().uuidString, path: .constant([]))
}

struct CompleteEmployeeProfileListView: View {
    @Binding var viewModel: CompleteEmployeeProfileViewModel
    var sizeCampo: CGFloat = 150
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CustomImageView(
                uiImage: $viewModel.selectedLocalImage,
                size: sizeCampo,
                searchFromInternet: nil,
                searchFromGallery: searchFromGallery,
                takePhoto: takePhoto
            )
            .photosPicker(isPresented: $viewModel.fields.isShowingPicker, selection: $viewModel.selectionImage, matching: .any(of: [.images, .screenshots]))
            CustomTextField(title: "Nombre" , value: $viewModel.fields.name, edited: .constant(false))
            CustomTextField(title: "Apellidos" , value: $viewModel.fields.lastName, edited: .constant(false))
            CustomTextField(title: "Correo" , value: $viewModel.fields.email, edited: .constant(false))
            CustomTextField(title: "Móvil" , value: $viewModel.fields.phone, edited: .constant(false))
            CustomTextField(title: "Rol" , value: .constant(viewModel.fields.role.description), edited: .constant(false), disable: true)
        }
        .padding(.horizontal, 10)
        .background(Color.background)
    }
    private func searchFromGallery() {
        viewModel.fields.isShowingPicker = true
    }
    private func takePhoto() {
        
    }
}
