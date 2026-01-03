import SwiftUI
import FlorShopDTOs

struct AddEmployeeView: View {
    @Environment(FlorShopRouter.self) private var router
    @Environment(OverlayViewModel.self) private var overlayViewModel
    @State var addEmployeeViewModel: AddEmployeeViewModel
    init(ses: SessionContainer) {
        self.addEmployeeViewModel = AddEmployeeViewModelFactory.getAddEmployeeViewModel(sessionContainer: ses)
    }
    var body: some View {
        AddEmployeeListController(addEmployeeViewModel: $addEmployeeViewModel)
            .navigationTitle("Invitar empleado")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                MainConfirmationToolbar(disabled: false, action: inviteEmployee)
            }
    }
    
    private func inviteEmployee() {
        let loadingId = self.overlayViewModel.showLoading()
        Task {
            do {
                try await self.addEmployeeViewModel.inviteEmployee()
                router.back()
                self.overlayViewModel.endLoading(id: loadingId)
            } catch {
                print("Error al registrar invitacion de empleado: \(error.localizedDescription)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al registrar invitacion de empleado.",
                    primary: AlertAction(
                        title: "Aceptar",
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
    @Previewable @State var overlayViewModel = OverlayViewModel()
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    AddEmployeeView(ses: SessionContainer.preview)
        .environment(mainRouter)
        .environment(overlayViewModel)
}

struct AddEmployeeListController: View {
    @Binding var addEmployeeViewModel: AddEmployeeViewModel
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                CustomTextField(placeHolder: "", title: "Correo" , value: $addEmployeeViewModel.email, edited: .constant(false))
                DropDownView(
                    hind: "Role",
                    options: UserSubsidiaryRole.allCases,
                    anchor: .bottom,
                    selection: $addEmployeeViewModel.role
                )
            }
        }
        .padding(.horizontal, 10)
        .background(Color.background)
    }
}

