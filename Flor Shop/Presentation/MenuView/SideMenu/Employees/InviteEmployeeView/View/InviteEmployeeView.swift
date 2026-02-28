import SwiftUI
import FlorShopDTOs

struct InviteEmployeeView: View {
    @Environment(FlorShopRouter.self) private var router
    @Environment(OverlayViewModel.self) private var overlayViewModel
    @State var viewModel: InviteEmployeeViewModel
    init(ses: SessionContainer) {
        self.viewModel = InviteEmployeeViewModelFactory.getInviteEmployeeViewModel(sessionContainer: ses)
    }
    var body: some View {
        InviteEmployeeListController(viewModel: $viewModel)
            .navigationTitle("Invitar empleado")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                MainConfirmationToolbar(disabled: false, action: inviteEmployee)
            }
    }
    
    private func inviteEmployee() {
        let loadingId = self.overlayViewModel.showLoading(origin: "[AddEmployeeView]")
        Task {
            do {
                try await self.viewModel.inviteEmployee()
                router.back()
                self.overlayViewModel.endLoading(id: loadingId, origin: "[AddEmployeeView]")
            } catch {
                print("Error al registrar invitacion de empleado: \(error.localizedDescription)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al registrar invitacion de empleado.",
                    primary: ConfirmAction(
                        title: "Aceptar",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId, origin: "[AddEmployeeView]")
                        }
                    )
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var overlayViewModel = OverlayViewModel()
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    InviteEmployeeView(ses: SessionContainer.preview)
        .environment(mainRouter)
        .environment(overlayViewModel)
}

struct InviteEmployeeListController: View {
    @Binding var viewModel: InviteEmployeeViewModel
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                CustomTextField(title: "Correo" , value: $viewModel.email, edited: .constant(false))
                DropDownView(
                    hind: "Role",
                    options: UserSubsidiaryRole.allCases,
                    anchor: .bottom,
                    selection: $viewModel.role
                )
            }
        }
        .padding(.horizontal, 10)
        .background(Color.background)
    }
}

