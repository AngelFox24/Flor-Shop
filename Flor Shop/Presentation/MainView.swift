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
    @State var webSocket: SyncWebSocketClient
    //TODO: Verificar si no perjudica a las vistar con el repintado
    let sessionContainer: SessionContainer
    init(sessionConfig: SessionConfig) {
        self.sessionContainer = SessionContainer(sessionConfig: sessionConfig)
        self.webSocket = SyncWebSocketClientFactory.getWebSocketClient(sessionContainer: sessionContainer)
    }
    var body: some View {
        VStack(spacing: 0) {
            MenuView()
                .environment(sessionContainer)
                .environment(webSocket)
        }
        .onAppear {
            self.initialization()
            self.connectWebSocket()
        }
    }
    private func initialization() {
        do {
            try self.sessionContainer.cartRepository.createCartIdNotExist()
        } catch {
            self.overlayViewModel.showAlert(
                title: "Error Websocket",
                message: "Ha ocurrido un error en la incializacion.",
                primary: AlertAction(title: "Aceptar", action: {})
            )
        }
    }
    private func connectWebSocket() {
        Task {
            do {
                try await webSocket.connect(
                    subdomain: self.sessionContainer.session.subdomain,
                    subsidiaryCic: self.sessionContainer.session.subsidiaryCic
                )
            } catch {
                self.overlayViewModel.showAlert(
                    title: "Error Websocket",
                    message: "Ha ocurrido un error en la sincronización.",
                    primary: AlertAction(title: "Aceptar") {
                        webSocket.disconnect()
                        self.sessionManager.logout()
                    }
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var overlayViewModel = OverlayViewModel()
    MainView()
        .environment(overlayViewModel)
}
