import SwiftUI
import FlorShopDTOs

struct CompanySelectionView: View {
    @Environment(SessionManager.self) var sessionManager
    @Environment(OverlayViewModel.self) var overlayViewModel
    @Binding var path: [SessionRoutes]
    @State private var viewModel: CompanySelectionViewModel
    @State private var companies: [CompanyResponseDTO] = []
    let provider: AuthProvider
    let token: String
    init(provider: AuthProvider, token: String, path: Binding<[SessionRoutes]>) {
        self.viewModel = CompanySelectionViewModelFactory.getViewModel()
        self.provider = provider
        self.token = token
        self._path = path
    }
    var body: some View {
        CompanySelectionListView(path: $path, viewModel: viewModel, companies: companies)
            .background(Color.background)
            .navigationTitle("Seleccione la compañía")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await self.loadInfo()
            }
    }
    private func loadInfo() async {
        let loadingId = self.overlayViewModel.showLoading(origin: "[CompanySelectionView]")
        do {
            let companies = try await self.sessionManager.login(provider: self.provider, token: self.token)
            await MainActor.run {
                self.companies = companies
            }
            self.overlayViewModel.endLoading(id: loadingId, origin: "[CompanySelectionView]")
        } catch {
            self.overlayViewModel.showAlert(
                title: "Error",
                message: "Ocurrio un error en la conexión. Intente nuevamente.",
                primary: ConfirmAction(
                    title: "Ok",
                    action: {
                        self.overlayViewModel.endLoading(id: loadingId, origin: "[CompanySelectionView]")
                    }
                )
            )
        }
    }
}

#Preview {
    @Previewable @State var overlayViewModel = OverlayViewModel()
    @Previewable @State var sessionManager = SessionManager(sessionRepository: SessionRepositoryImpl.mock())
    CompanySelectionView(provider: .google, token: "", path: .constant([]))
        .environment(sessionManager)
        .environment(overlayViewModel)
}

struct CompanySelectionListView: View {
    @Binding var path: [SessionRoutes]
    var viewModel: CompanySelectionViewModel
    let companies: [CompanyResponseDTO]
    var body: some View {
        HStack(spacing: 0) {
            if companies.isEmpty {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Image("groundhog_finding")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                        Text("No tienes ninguna empresa asociada.")
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
                        ForEach(companies) { companyDTO in
                            Button {
                                self.path.append(.subsidiarySelection(companyCic: companyDTO.company_cic))
                            } label: {
                                CardViewTipe1(
                                    imageUrl: nil,
                                    topStatusColor: companyDTO.is_company_owner ? Color.accentColor : .clear,
                                    topStatus: companyDTO.is_company_owner ? "Dueño" : "",
                                    mainText: companyDTO.name,
                                    secondaryText: "",
                                    size: 80
                                )
                                .contentShape(Rectangle()) // hace que todo el card sea clicable
                                .padding(.horizontal, 10)
                            }
                        }
                    }
                }
            }
        }
    }
}
