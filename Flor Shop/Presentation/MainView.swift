import SwiftUI

struct MainView: View {
    @Environment(SessionManager.self) var session
    init() {
        print("[MainView] Init.")
    }
    var body: some View {
        VStack {
            if let session = session.sessionContainer {
                MainContendView()
                    .environment(session)
            } else {
                WelcomeView()
            }
        }
    }
}

enum MainViewState {
    case completeProfile
    case iddle
}

struct MainContendView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(OverlayViewModel.self) var overlayViewModel
    @Environment(SessionManager.self) var sessionManager
    @Environment(SessionContainer.self) var sessionContainer
    @State var state: MainViewState = .completeProfile
    init() {
        print("[MainContendView] Init.")
    }
    var body: some View {
        VStack(spacing: 0) {
            switch state {
            case .completeProfile:
                CompleteEmployeeProfileView(ses: sessionContainer, state: $state)
            case .iddle:
                MenuView()
            }
        }
        .onChange(of: scenePhase) { oldScene, newScene in
            print("[Pow] oldScene: \(oldScene) newScene: \(newScene)")

            switch newScene {
            case .background:
                print("[MainContendView] App en background")
                self.endConection()

            case .active:
                print("[MainContendView] App en uso")
                Task {
                    try? await sessionContainer.powerSyncService.connect()
                }

            case .inactive:
                print("[MainContendView] App inactive")

            @unknown default:
                break
            }
        }
        .task {
            await self.connectPowerSync()
            await self.initialization()
        }
    }
    private func endConection() {
//        Task {
//            do {
//                try await self.sessionContainer.powerSyncService.disconnect()
//            } catch {
//                print("[MainContendView] Error al desconectar a PowerSync: \(error)")
//            }
//        }
    }
    private func initialization() async {
        print("[MainContendView] initialization func")
        let loadingId = self.overlayViewModel.showLoading(origin: "[MainContendView]")
        do {
            if try await !self.sessionContainer.subsidiaryRepository.initialDataExist() {
                try await self.sessionContainer.companyRepository.initialData()
            }
            try await self.sessionContainer.cartRepository.initializeModel()
            try await self.sessionContainer.powerSyncService.waitForFirstSync()
            if try await !self.sessionContainer.employeeRepository.isEmployeeProfileComplete() {
                self.state = .completeProfile
            } else {
                try await self.sessionContainer.cartRepository.createCartIfNotExists()
                self.state = .iddle
            }
            self.overlayViewModel.endLoading(id: loadingId, origin: "[MainContendView]")
        } catch {
            print("[MainContendView] Error: \(error)")
            self.overlayViewModel.showAlert(
                title: "Error en la inicializacion.",
                message: "Ha ocurrido un error en la incializacion.",
                primary: ConfirmAction(title: "Aceptar") {
                    self.overlayViewModel.endLoading(id: loadingId, origin: "[MainContendView]")
//                    self.sessionManager.logout()
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
//                    self.sessionManager.logout()
                }
            )
        }
    }
    private func connectPowerSyncTask() {
//        let loadingId = self.overlayViewModel.showLoading(origin: "[MainContendView]")
        Task {
            await connectPowerSync()
//            self.overlayViewModel.endLoading(id: loadingId, origin: "[MainContendView]")
            await self.initialization()
        }
    }
}

#Preview {
    @Previewable @State var overlayViewModel = OverlayViewModel()
    MainView()
        .environment(overlayViewModel)
}
