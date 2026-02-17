import SwiftUI

struct MainView: View {
    @State private var session: SessionManager
    init() {
        self.session = SessionManagerFactory.getSessionManager()
    }
    var body: some View {
        VStack {
            switch session.state {
            case .loggedOut:
                WelcomeView()
            case .loggedIn(let sessionConfig):
                MainContendView(sessionConfig: sessionConfig)
            }
        }
        .environment(session)
    }
}

struct MainContendView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(OverlayViewModel.self) var overlayViewModel
    @Environment(SessionManager.self) var sessionManager
    //TODO: Verificar si no perjudica a las vistar con el repintado
    let sessionContainer: SessionContainer
    init(sessionConfig: SessionConfig) {
        self.sessionContainer = SessionContainer(sessionConfig: sessionConfig)
    }
    var body: some View {
        VStack(spacing: 0) {
            MenuView()
                .environment(sessionContainer)
        }
        .onChange(of: scenePhase) { oldScene, newScene in
            if newScene == .inactive {
                self.endConection()
            } else if newScene == .active {
//                await self.connectPowerSync()
                print("[MainContendView] App en uso")
                connectPowerSyncTask()
            }
        }
        .task {
            await self.connectPowerSync()
            await self.initialization()
        }
    }
    private func endConection() {
        Task {
            do {
                try await self.sessionContainer.powerSyncService.disconnect()
            } catch {
                print("[MainContendView] Error al desconectar a PowerSync: \(error)")
            }
        }
    }
    private func initialization() async {
        let loadingId = self.overlayViewModel.showLoading(origin: "[MainContendView]")
        do {
            try await self.sessionContainer.cartRepository.initializeModel()
            try await self.sessionContainer.powerSyncService.waitForFirstSync()
            self.overlayViewModel.endLoading(id: loadingId, origin: "[MainContendView]")
        } catch {
            self.overlayViewModel.showAlert(
                title: "Error en la inicializacion.",
                message: "Ha ocurrido un error en la incializacion.",
                primary: ConfirmAction(title: "Aceptar") {
//                    self.overlayViewModel.endLoading(id: loadingId, origin: "[MainContendView]")
                }
            )
        }
    }
    private func connectPowerSync() async {
        do {
            try await self.sessionContainer.powerSyncService.connect()
        } catch {
            print("[MainContendView] Error al contectar a PowerSync: \(error)")
            self.overlayViewModel.showAlert(
                title: "Error al contectar a PowerSync",
                message: "Ha ocurrido un error en la sincronización.",
                primary: ConfirmAction(title: "Aceptar") {
                    self.sessionManager.logout()
                }
            )
        }
    }
    private func connectPowerSyncTask() {
        let loadingId = self.overlayViewModel.showLoading(origin: "[MainContendView]")
        Task {
            await connectPowerSync()
            self.overlayViewModel.endLoading(id: loadingId, origin: "[MainContendView]")
            await self.initialization()
        }
    }
}

#Preview {
    @Previewable @State var overlayViewModel = OverlayViewModel()
    MainView()
        .environment(overlayViewModel)
}
