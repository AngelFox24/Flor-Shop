import SwiftUI
import Equatable
import FlorShopDTOs

@Equatable(isolation: .isolated)
struct SubsidiarySelectionView: View {
    @Environment(SessionManager.self) var sessionManager
    @Environment(OverlayViewModel.self) var overlayViewModel
    @Binding var path: [SessionRoutes]
    @State private var viewModel: SubsidiarySelectionViewModel
    @State var subsidiaries: [SubsidiaryResponseDTO] = []
    let companyCic: String
    init(companyCic: String, path: Binding<[SessionRoutes]>) {
        print("[SubsidiarySelectionView] Init")
        self.viewModel = SubsidiarySelectionViewModelFactory.getViewModel()
        self.companyCic = companyCic
        self._path = path
    }
    var body: some View {
        let _ = Self._printChanges()
        SubsidiarySelectionListView(viewModel: viewModel, subsidiaries: subsidiaries)
            .background(Color.background)
            .navigationTitle("Seleccione la sucursal")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // TODO: Revisar invalidaciones/re-renderizados innecesarios.
                // Cuando `selectSubsidiary` asigna `sessionContainer` dentro de SessionManager,
                // MainView cambia de WelcomeView -> MainContentView.
                // Sin embargo, antes de salir completamente de jerarquía,
                // SubsidiarySelectionView vuelve a invalidarse/re-renderizarse y `.task`
                // se ejecuta nuevamente, generando requests duplicados/cancelados
                // (`URLError.cancelled` -999).
                // Investigar por qué el cambio observable de `@Environment(SessionManager.self)`
                // provoca una nueva reconciliación/montaje de esta vista en lugar de desmontarla directamente.
                await loadInfo()
            }
    }
    private func loadInfo() async {
        let loadingId = self.overlayViewModel.showLoading(origin: "[SubsidiarySelectionView]")
        do {
            print("[SubsidiarySelectionView] Loading subsidiaries")
            let subsidiaries = try await self.sessionManager.getSubsidiaries(companyCic: self.companyCic)
            print("[SubsidiarySelectionView] Finished loading subsidiaries")
            await MainActor.run {
                self.subsidiaries = subsidiaries
            }
            self.overlayViewModel.endLoading(id: loadingId, origin: "[SubsidiarySelectionView]")
        } catch is CancellationError {
            print("[SubsidiarySelectionView] Task cancelled")
            self.overlayViewModel.endLoading(
                id: loadingId,
                origin: "[SubsidiarySelectionView]"
            )
        } catch let error as URLError where error.code == .cancelled {
            print("[SubsidiarySelectionView] URLSession cancelled")
            self.overlayViewModel.endLoading(
                id: loadingId,
                origin: "[SubsidiarySelectionView]"
            )
        } catch {
            print("[SubsidiarySelectionView] Error: \(error)")
            self.overlayViewModel.showAlert(
                title: "Error",
                message: "Ocurrio un error en la conexión. Intente nuevamente.",
                primary: ConfirmAction(
                    title: "Ok",
                    action: {
                        self.overlayViewModel.endLoading(id: loadingId, origin: "[SubsidiarySelectionView]")
                    }
                )
            )
        }
    }
}

#Preview {
    SubsidiarySelectionView(companyCic: UUID().uuidString, path: .constant([]))
}

struct SubsidiarySelectionListView: View {
    @Environment(SessionManager.self) var sessionManager
    var viewModel: SubsidiarySelectionViewModel
    let subsidiaries: [SubsidiaryResponseDTO]
    var body: some View {
        let _ = Self._printChanges()
        HStack(spacing: 0) {
            if subsidiaries.isEmpty {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Image("groundhog_finding")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                        Text("Aún no tiene ninguna sucursal asociada.")
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .font(.custom("Artifika-Regular", size: 18))
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(subsidiaries) { subsidiaryDTO in
                            Button {
                                selectSubsidiary(subsidiaryCic: subsidiaryDTO.subsidiary_cic)
                            } label: {
                                CardViewTipe1(
                                    imageUrl: nil,
                                    topStatusColor: .clear,
                                    topStatus: "",
                                    mainText: subsidiaryDTO.name,
                                    secondaryText: subsidiaryDTO.subsidiary_role.rawValue,
                                    size: 80
                                )
                                .padding(.horizontal, 10)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                                .listRowBackground(Color.background)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func selectSubsidiary(subsidiaryCic: String) {
        Task {
            let _ = try await self.sessionManager.selectSubsidiary(subsidiaryCic: subsidiaryCic)
        }
    }
}
