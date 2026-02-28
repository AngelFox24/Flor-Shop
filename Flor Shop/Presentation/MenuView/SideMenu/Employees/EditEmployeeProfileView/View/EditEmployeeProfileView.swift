import SwiftUI
import FlorShopDTOs

struct EditEmployeeProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(FlorShopRouter.self) var florShopRouter
    @State private var viewModel: EditEmployeeProfileViewModel
    let employeeCic: String
    init(employeeCic: String, ses: SessionContainer) {
        self.viewModel = EditEmployeeProfileViewModelFactory.getViewModel(sessionContainer: ses)
        self.employeeCic = employeeCic
    }
    var body: some View {
        EditEmployeeProfileListView(viewModel: $viewModel)
            .navigationTitle("Complete su perfil")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.background)
            .disabled(viewModel.isLoading)
            .alert(alert: $viewModel.alert, alertInfo: viewModel.alertInfo)
            .toolbar {
                MainConfirmationAsyncToolbar(disabled: false, isLoading: viewModel.isLoading, action: viewModel.saveEmployeeTransaccion)
            }
            .task(id: self.viewModel.editEmployeeTransaction) {
                guard case let .edit(employeeCic) = viewModel.editEmployeeTransaction else { return }
                await self.viewModel.saveEmployeeProfile(employeeCic: employeeCic, dismiss: dismiss)
                self.viewModel.editEmployeeTransaction = .none
            }
            .task {
                await self.viewModel.loadEmployeeProfile(employeeCic: employeeCic, dismiss: dismiss)
            }
    }
}

#Preview {
    @Previewable @State var overlayModel = OverlayViewModel()
    EditEmployeeProfileView(employeeCic: UUID().uuidString, ses: SessionContainer.preview)
        .environment(overlayModel)
}

struct EditEmployeeProfileListView: View {
    @Binding var viewModel: EditEmployeeProfileViewModel
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
            .disabled(viewModel.fields.isPickerDisable)
            CustomTextField(title: "Nombre" , value: $viewModel.fields.name, edited: .constant(false), disable: viewModel.fields.isNameDisable)
            CustomTextField(title: "Apellidos" , value: $viewModel.fields.lastName, edited: .constant(false), disable: viewModel.fields.isLastNameDisable)
            CustomTextField(title: "Correo" , value: $viewModel.fields.email, edited: .constant(false), disable: viewModel.fields.isEmailDisable)
            CustomTextField(title: "Móvil" , value: $viewModel.fields.phone, edited: .constant(false), disable: viewModel.fields.isPhoneDisable)
            CustomTextField(title: "Rol" , value: .constant(viewModel.fields.role.description), edited: .constant(false), disable: viewModel.fields.isRoleDisable)
        }
        .padding(.horizontal, 10)
    }
    private func searchFromGallery() {
        viewModel.fields.isShowingPicker = true
    }
    private func takePhoto() {
        
    }
}
