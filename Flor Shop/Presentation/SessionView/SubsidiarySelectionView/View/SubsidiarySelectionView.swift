import SwiftUI
import FlorShopDTOs

struct SubsidiarySelectionView: View {
    @Environment(SessionManager.self) var sessionManager
    @Environment(OverlayViewModel.self) var overlayViewModel
    @Binding var path: [SessionRoutes]
    @State private var viewModel: SubsidiarySelectionViewModel
    @State var subsidiaries: [SubsidiaryResponseDTO] = []
    let companyCic: String
    init(companyCic: String, path: Binding<[SessionRoutes]>) {
        self.viewModel = SubsidiarySelectionViewModelFactory.getViewModel()
        self.companyCic = companyCic
        self._path = path
    }
    var body: some View {
        SubsidiarySelectionListView(viewModel: viewModel, subsidiaries: subsidiaries, path: $path)
            .background(Color.background)
            .navigationTitle("Seleccione la sucursal")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadInfo()
            }
    }
    private func loadInfo() async {
        let loadingId = self.overlayViewModel.showLoading()
        do {
            let subsidiaries = try await self.sessionManager.getSubsidiaries(companyCic: self.companyCic)
            await MainActor.run {
                self.subsidiaries = subsidiaries
            }
            self.overlayViewModel.endLoading(id: loadingId)
        } catch {
            self.overlayViewModel.showAlert(
                title: "Error",
                message: "Ocurrio un error en la conexión. Intente nuevamente.",
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

#Preview {
    SubsidiarySelectionView(companyCic: UUID().uuidString, path: .constant([]))
}

struct SubsidiarySelectionListView: View {
    @Environment(SessionManager.self) var sessionManager
    var viewModel: SubsidiarySelectionViewModel
    let subsidiaries: [SubsidiaryResponseDTO]
    @Binding var path: [SessionRoutes]
    var body: some View {
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
            let session = try await self.sessionManager.selectSubsidiary(subsidiaryCic: subsidiaryCic)
            self.path.append(.completeEmployeeProfile(subsidiaryCic: session.subsidiaryCic, subdomain: session.subdomain))
        }
    }
}
