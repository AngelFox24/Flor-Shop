import SwiftUI
import FlorShopDTOs

struct CompleteEmployeeProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(OverlayViewModel.self) var overlayViewModel
    @Environment(FlorShopRouter.self) var florShopRouter
    @State private var viewModel: CompleteEmployeeProfileViewModel
    init(ses: SessionContainer) {
        self.viewModel = CompleteEmployeeProfileViewModelFactory.getViewModel(sessionContainer: ses)
    }
    var body: some View {
        CompleteEmployeeProfileListView(viewModel: $viewModel)
            .navigationTitle("Complete su perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                MainConfirmationToolbar(disabled: false, action: completeProfile)
            }
    }
    private func completeProfile() {
        let loadingId = self.overlayViewModel.showLoading(origin: "[CompleteEmployeeProfileView]")
        Task {
            do {
                try await self.viewModel.completeEmployeeProfile()
                dismiss()
                self.overlayViewModel.endLoading(id: loadingId, origin: "[CompleteEmployeeProfileView]")
            } catch {
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ocurrio un error al completar el perfil. Intente nuevamente.",
                    primary: ConfirmAction(
                        title: "Ok",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId, origin: "[CompleteEmployeeProfileView]")
                        }
                    )
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var overlayModel = OverlayViewModel()
    CompleteEmployeeProfileView(ses: SessionContainer.preview)
        .environment(overlayModel)
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
//        .background(Color.background)
    }
    private func searchFromGallery() {
        viewModel.fields.isShowingPicker = true
    }
    private func takePhoto() {
        
    }
}
